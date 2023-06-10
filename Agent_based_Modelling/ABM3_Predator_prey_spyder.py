#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 30 13:24:12 2023

@author: pascal
"""

from pylab import *
import copy as cp

prey0 = 100 # initial prey population
prey_m = 0.03 # prey max movement size 
prey_d = 1 # prey death rate if close to predator
prey_r = 0.1 # reproduction rate of prey

pred0 = 30 # initial predator population
pred_m = 0.05 # prey max movement size
pred_d = 0.1 # predator death rate by starvation 
pred_r = 0.7# reproduction rate of predator

K = 500 # prey carrying capacity
r = 0.01 # proximity radius 

# other interesting sets

#in this set, predators remain constant and regulate prey ize
prey0 = 100 # initial prey population
prey_m = 0.03 # prey max movement size 
prey_d = 0.9 # prey death rate if close to predator
prey_r = 0.6 # reproduction rate of prey

pred0 = 30 # initial predator population
pred_m = 0.05 # prey max movement size
pred_d = 0.1 # predator death rate by starvation 
pred_r = 0.3# reproduction rate of predator

# good set to show cycles
prey0 = 100 # initial prey population
prey_m = 0.03 # prey max movement size 
prey_d = 1 # prey death rate if close to predator
prey_r = 0.1 # reproduction rate of prey

pred0 = 30 # initial predator population
pred_m = 0.05 # prey max movement size
pred_d = 0.1 # predator death rate by starvation 
pred_r = 0.5# reproduction rate of predator

# STABLE with r=0.01
prey0 = 100 # initial prey population
prey_m = 0.03 # prey max movement size 
prey_d = 1 # prey death rate if close to predator
prey_r = 0.1 # reproduction rate of prey

pred0 = 30 # initial predator population
pred_m = 0.05 # prey max movement size
pred_d = 0.1 # predator death rate by starvation 
pred_r = 0.7# reproduction rate of predator

K = 500 # prey carrying capacity
r = 0.01 # proximity radius 

class agent: # define agent class for preys and predators
    pass

def initialise():
    # we need to start with empty lists of agents, and data on prey and predators
    # must be global elements, so that their values can be used by other functions
    global agents, preydata, preddata
    agents = []
    preydata = []
    preddata = []
    
    for i in range(prey0 + pred0):
    # prey0 + pred0 is total number of agents    
        ag = agent() 
        ag.type = 'prey' if i < prey0 else 'pred' 
        # creates prey0 preys and pred0 predators
        ag.x = random() # creates them in random x,y positions
        ag.y = random()
        agents.append(ag) # appends each created ag to agents list

def observe():
    global agents, preydata, preddata # the three lists required for plotting
    
    subplot(1, 2, 1) # subplot: (rows=1, columns=2, position=1 or left) 
    cla() # clear previous plot
    
    preys = [ag for ag in agents if ag.type == 'prey'] # select preys
    if len(preys) > 0: # if there is still any prey alive
        x = [ag.x for ag in preys] # plot in space
        y = [ag.y for ag in preys]
        plot(x, y, 'b.') # plot in blue, small circle
    
    predators = [ag for ag in agents if ag.type == 'pred'] #select predators
    if len(predators) > 0:
        x = [ag.x for ag in predators]
        y = [ag.y for ag in predators]
        plot(x, y, 'ro') # red, large circles
    
    axis('image') # fits plot into limits below
    axis([0, 1, 0, 1]) # x (0, 1) and y (0, 1) limits 

    subplot(1, 2, 2) # rows 1, columns 2, position 2 =  right
    cla()
    plot(preydata, label = 'prey') # plots prey and pred populations; see end of code
    plot(preddata, label = 'predator')
    legend() # show label above as legend

def update_agent(): # this will update only one agent asynchronously
    global agents
    if agents == []: # if all agents are dead, do nothing
        return
    ag = choice(agents) # otherwise select an agent to update

    # simulating random movement
    m = prey_m if ag.type == 'prey' else pred_m # select rate
    ag.x += uniform(-m, m)
    ag.y += uniform(-m, m)
    ag.x = 1 if ag.x > 1 else 0 if ag.x < 0 else ag.x # agent must stay within plot area 
    ag.y = 1 if ag.y > 1 else 0 if ag.y < 0 else ag.y

    # detecting a close agent
    neighbours = [nb for nb in agents if nb.type != ag.type 
                 and (ag.x - nb.x)**2 + (ag.y - nb.y)**2 < r**2]
                # if distance to an agent of the other 
                # type is less than radius r, include it in neighbour list
    
    if ag.type == 'prey': # if agent is prey
        if len(neighbours) > 0: # if there are predators in neighbourhood
            if random() < prey_d: # agent dies with probability prey_d
                agents.remove(ag)
                rep_pred = choice(neighbours)
                if random() < pred_r: # and predator reproduces with prob pred_r
                    agents.append(cp.copy(rep_pred)) # offspring is a copy of parent and added to agents list 
            else: # if prey survives
                if random() < prey_r*(1-sum([1 for x in agents if x.type == 'prey'])/K):# prey reproduces with rate prey_r
                    agents.append(cp.copy(ag))       
        else: # if there are not predators
            if random() < prey_r*(1-sum([1 for x in agents if x.type == 'prey'])/K):
                agents.append(cp.copy(ag))
            # above: prey reproduces with rate prey_r,
            # times how close it is to carrying capacity
            # offspring is a copy of parent, and is appended to agents list
    
    else: # if agent is predator
        if len(neighbours) == 0: # if there are no preys nearby
            if random() < pred_d: # predator dies with rate pred_d
                agents.remove(ag)
                return
            
        else: # if there are prey nearby
            if random() < prey_d: # if predator is successful:
                dead_prey = choice(neighbours) # a prey dies
                agents.remove(dead_prey)
                if random() < pred_r: # and predator reproduces with rate pred_r
                    agents.append(cp.copy(ag)) # offspring is a copy of parent and added to agents list 
               
#EX1 
def update():
    global agents, preydata, preddata, preymob, predmob
    t = 0
    while t < 1 and len(agents) > 0:
        t += 1 / len(agents) #adding 1/len(agents) to t every update until t > 1
        update_agent()

    preydata.append(sum([1 for x in agents if x.type == 'prey'])) # counts agents per type in each round
    preddata.append(sum([1 for x in agents if x.type == 'pred']))
    
 
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
        
    