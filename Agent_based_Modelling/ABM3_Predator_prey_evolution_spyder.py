#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 30 13:56:09 2023

@author: pascal
"""

from pylab import *
import copy as cp
from numba import njit

prey0 = 400 # initial prey population
K = 500 # carrying capacity of prey
prey_m = 0.03 # magnitude of movement of prey
prey_d = 0.8 # death rate of prey
prey_r = 0.1 # reproduction rate of prey

pred0 = 100 # initial predator population
MaxPred = 1000 # max number of predators
pred_m = 0.05 # magnitude of movement of predators
pred_d = 0.1 # death rate of predators
pred_r = 0.5 # reproduction rate of predators

r = 0.01 # 0.02 radius for proximity detection
mut = 0.01 # mutation rate

class agent:
    pass

def initialise():
    #create lists for agents, populations, mobility, and reproduction
    global agents, preydata, preddata, preymob, predmob, preyrep, predrep 
    agents = []
    preydata = []
    preddata = []
    preymob = []
    predmob = []
    preyrep = []
    predrep = []
    
    for i in range(prey0 + pred0):
        ag = agent()
        ag.type = 'prey' if i < prey0 else 'pred'
        ag.x = random()
        ag.y = random()
        ag.m = prey_m if i < prey0 else pred_m
        ag.r = prey_r if i < prey0 else pred_r
        agents.append(ag)

def observe():
    global agents, preydata, preddata, preymob, predmob, preyrep, predrep
    
    subplot(2, 2, 1) # now we need 2 rows and 2 columns for 4 plots; 1=top left
    cla()
    
    preys = [ag for ag in agents if ag.type == 'prey']
    if len(preys) > 0:
        x = [ag.x for ag in preys]
        y = [ag.y for ag in preys]
        plot(x, y, color='blue', marker='.', ls="") 
        # another way of setting colour and style, 
        # ls is line style,which we dont want 
    
    predators = [ag for ag in agents if ag.type == 'pred']
    if len(predators) > 0:
        x = [ag.x for ag in predators]
        y = [ag.y for ag in predators]
        plot(x, y, color = 'red', marker='o', ls="")
    axis('image')
    axis([-0.1, 1.1, -0.1, 1.1]) #notice extension

    subplot(2, 2, 2) # population plot
    cla()
    plot(preydata, label = 'prey', color="blue")
    plot(preddata, label = 'predator', color="red")
    title('Population')
    legend()

    subplot(2, 2, 3) # movement rate plot
    cla()
    plot(preymob, label = 'prey', color="blue")
    plot(predmob, label = 'predator', color="red")
    title('Movement rate')
    legend()
    
    subplot(2, 2, 4) # reproduction rate plot
    cla()
    plot(preyrep, label = 'prey', color="blue")
    plot(predrep, label = 'predator', color="red")
    title('Reproductive rate')
    legend()
    tight_layout()
    
def update_agent():
    global agents
    if agents == []:
        return
    ag = choice(agents)

   # detecting neighbours
    neighbours = [nb for nb in agents if nb.type != ag.type
                 and (ag.x - nb.x)**2 + (ag.y - nb.y)**2 < r**2]

    if ag.type == 'prey':
        mprey = ag.m
        rprey = ag.r
        if len(neighbours) > 0: # if there are predators nearby
            if random() < prey_d:
                agents.remove(ag)
                return
            else: # if you didn't die, run!
                ag.x += uniform(-mprey, mprey)
                ag.y += uniform(-mprey, mprey)
                ag.x = 1 if ag.x > 1 else 0 if ag.x < 0 else ag.x
                ag.y = 1 if ag.y > 1 else 0 if ag.y < 0 else ag.y        
        else: # reproduce if there are no predators
            if random() < rprey*(1-sum([1 for x in agents if x.type == 'prey'])/K):
                offspring = cp.copy(ag)
                offspring.m = ag.m + uniform(-mut, mut) # offspring movement mutates
                offspring.r = ag.r + uniform(-mut, mut) # offspring reproductive rate mutates
                agents.append(offspring)
            ag.x += 0.9*uniform(-mprey, mprey) # then agent moves, but at slower rate if there are no predators
            ag.y += 0.9*uniform(-mprey, mprey)
            ag.x = 1 if ag.x > 1 else 0 if ag.x < 0 else ag.x # stay uîside plot
            ag.y = 1 if ag.y > 1 else 0 if ag.y < 0 else ag.y        
          
    else: # if agent is a predator
        mpred = ag.m
        rpred = ag.r
        if len(neighbours) == 0: # if there are no prey nearby
            if random() < pred_d:
                agents.remove(ag)
                return
            else: # if no prey and predator doesnt die, predator must move
                ag.x += uniform(-mpred, mpred)
                ag.y += uniform(-mpred, mpred)
                ag.x = 1 if ag.x > 1 else 0 if ag.x < 0 else ag.x
                ag.y = 1 if ag.y > 1 else 0 if ag.y < 0 else ag.y
        
        else: # if there is prey nearby, stay and reproduce
            if random() < rpred*(1-sum([1 for x in agents if x.type == 'pred'])/MaxPred):
                offspring = cp.copy(ag)
                offspring.m = ag.m + uniform(-mut, mut)
                offspring.r = ag.r + uniform(-mut, mut)
                agents.append(offspring)

def update():
    global agents, preydata, preddata, preymob, predmob
    t = 0
    while t < 1 and len(agents) > 0:
        t += 1 / len(agents)
        update_agent()

    preydata.append(sum([1 for x in agents if x.type == 'prey'])) # store information on population, movement, reproduction
    preddata.append(sum([1 for x in agents if x.type == 'pred']))
    preymob.append(mean([t.m for t in agents if t.type == 'prey']))
    predmob.append(mean([t.m for t in agents if t.type == 'pred']))
    preyrep.append(mean([u.r for u in agents if u.type == 'prey']))
    predrep.append(mean([u.r for u in agents if u.type == 'pred']))
    

steps = 100   
flag = True
k = 0
initialise()
fig =figure()
# ax = add_subplot(1,2,1)
observe()

while flag: 
    k += 1
    update()
    if k%1 == 0:
        # ax.clear()
        observe()
        plt.pause(0.01)
