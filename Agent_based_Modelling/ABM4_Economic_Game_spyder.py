#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 31 10:09:13 2023

@author: pascal
"""

from numpy import *
from random import *
from pylab import *
import copy as cp

#parameters

#population and environment
h0 = 50 # initial h pop
d0 = 50 # initial d pop

spots = 8 #number of food patches
patches = range(8) # and their numbers 
abund = 20 # 20 # food items per patch
K = 1000 # carrying capacity

b0 = 5 # agent energy balance at start/ birth
#patchtypes = repeat(range(patch), abund)
deltabal = -0.15 # energy consumption per round
death_thresh = 0.1 # death if balance below this value
offcost =  8 # energy balance threshold for reproduction

# V>C for PD, V<C for HD
V = 1 # value of resource
C = 0.2 # cost of resource

r = 0.06 # radius for proximity
movrate = 0.05 # initial movement rate
mut = 0.03 # mutation rate of offspring

class agent():
    pass

def initialise(): # create lits for storage
    global agents, environ, pophawk, popdove,\
        payhawk, paydove, mobhawk, mobdove
    agents = [] 
    environ = []
    pophawk = []
    popdove = []
    payhawk = []
    paydove = []
    mobhawk = []
    mobdove = []
    
    for i in range(h0 + d0): # create agents
        ag = agent()
        ag.type = 'hawk' if i < h0 else 'dove'
        ag.x = random()
        ag.y = random()
        ag.mov = movrate
        ag.bal = b0
        agents.append(ag)
           
    for i in range(spots): # create food patches
        env = agent() # food patch env is an agent too
        env.spot = patches[i] # patch number
        env.x = random() # x and y location of patch i
        env.y = random()
        env.value = abund # food items in patch
        environ.append(env) # append to list of patches

def observe(): # observed lists  
    global agents, environ, pophawk, popdove,\
        payhawk, paydove, mobhawk, mobdove
    
    subplot(2, 2, 1) # main spatial plot 
    cla()

    # plot food patches:
    xfood = [ag.x for ag in environ] 
    yfood = [ag.y for ag in environ]
    plot(xfood, yfood, c = 'forestgreen',\
         marker = '8', ms = 20, ls = '') # no line connecting points
    # background colour:
    ax = gca() # get current axis
    ax.set_facecolor('peachpuff')
    
    #plot agents
    hawks = [ag for ag in agents if ag.type == 'hawk']
    if len(hawks) > 0:
        x = [ag.x for ag in hawks]
        y = [ag.y for ag in hawks]
        plot(x, y, c = 'indianred', marker = 'o', ms = 8, ls='')
    
    doves = [ag for ag in agents if ag.type == 'dove']
    if len(doves) > 0:
        x = [ag.x for ag in doves]
        y = [ag.y for ag in doves]
        plot(x, y, c = 'snow', marker = 'o', ms = 4, ls='')
    axis('image')
    axis([0, 1, 0, 1]) # x and y limits of plot
        
    subplot(2 ,2 ,3) # plot movement rate
    cla()
    plot(mobhawk, label = 'hawk', c = 'indianred')
    plot(mobdove, label = 'dove', c = 'lightgrey')
    title('Movement rate')
    legend()
   
    subplot(2, 2, 2) # plot population
    cla()
    plot(pophawk, label = 'hawks', c = 'indianred')
    plot(popdove, label = 'dove', c = 'lightgrey')
    title('Population')
    legend()
    
    subplot(2, 2, 4) # plot payoffs 
    cla()
    plot(payhawk, label = 'hawks', c = 'indianred')
    plot(paydove, label = 'dove', c = 'lightgrey')
    title('Payoffs')
    legend()
    
    tight_layout()
  
def update_agent(): 
    global agents, environ, spots # update per step
    
    if agents == []: # if no agents or food patch, stop
        return
    if environ == []:
        return
    
    ag = choice(agents) # otherwise select agent
    ag.bal += deltabal # reduce its balance (cost of being alive)
    # list of food patches nearby
    foodplace = [fd for fd in environ if \
                  (fd.x - ag.x)**2 + (fd.y - ag.y)**2 < r**2]
    # list of neighbours nearby
    neighbours = [nb for nb in agents if \
                  (nb.x - ag.x)**2 + (nb.y - ag.y)**2 < r**2]    
    
    if len(foodplace) > 0: # if there is food
        fp = choice(foodplace) # choose food patch
        if len(neighbours) > 0: #if ag has neighbours
            nb = choice(neighbours) # select a neighbour 
            nb.bal += deltabal # Reduce nb energy
            if ag.type == 'hawk': 
                if nb.type == 'hawk':# if ag=hawk and nb=hawk:
                    ag.bal += (V - C)/2 # payoff to hawk
                    mrate = ag.mov # ag moves because of the cost
                    ag.x += uniform(-mrate, mrate)
                    ag.y += uniform(-mrate, mrate)                   
                    ag.x = 1 if ag.x > 1 else 0 if ag.x < 0 else ag.x
                    ag.y = 1 if ag.y > 1 else 0 if ag.y < 0 else ag.y   

                    nb.bal += (V - C)/2 # payoff to hawk
                    nrate = nb.mov
                    nb.x += uniform(-nrate, nrate) # also moves
                    nb.y += uniform(-nrate, nrate)
                    nb.x = 1 if nb.x > 1 else 0 if nb.x < 0 else nb.x
                    nb.y = 1 if nb.y > 1 else 0 if nb.y < 0 else nb.y   

                else: # nb is dove
                    ag.bal += V # payoff to hawk; stays where it is
                    # nb.bal += 0 ; dove gets 0, no need to update  
                    nrate = nb.mov
                    nb.x += uniform(-nrate, nrate)
                    nb.y += uniform(-nrate, nrate)
                    nb.x = 1 if nb.x > 1 else 0 if nb.x < 0 else nb.x
                    nb.y = 1 if nb.y > 1 else 0 if nb.y < 0 else nb.y   
                    
            else: #ag is dove
                if nb.type == 'hawk':
                    nb.bal += V 
                    mrate = ag.mov
                    ag.x += uniform(-mrate, mrate)
                    ag.y += uniform(-mrate, mrate)
                    ag.x = 1 if ag.x > 1 else 0 if ag.x < 0 else ag.x
                    ag.y = 1 if ag.y > 1 else 0 if ag.y < 0 else ag.y                     
                    
                else: # nb is dove; they dont move
                    ag.bal += V/2  
                    nb.bal += V/2
        
        else: ag.bal += V # if no neighbours, resource goes to agent      
        
        fp.value += - V 
        if fp.value <=0: 
            fp.value = abund
            fp.x = random()
            fp.y = random()
       
    else: # no food around, move
        mrate = ag.mov
        ag.x += uniform(-mrate, mrate)
        ag.y += uniform(-mrate, mrate)
        ag.x = 1 if ag.x > 1 else 0 if ag.x < 0 else ag.x
        ag.y = 1 if ag.y > 1 else 0 if ag.y < 0 else ag.y   
    

    #death and rep of agent
    if ag.bal <= death_thresh: # if energy balance below thresh, agent dies
        agents.remove(ag)
    elif ag.bal*(1-len(agents)/K)>= offcost: # otherwise agent reproduces, considering K 
        offspring_ag = cp.copy(ag)
        offspring_ag.mov = ag.mov + uniform(-mut, mut)
        offspring_ag.bal = b0
        agents.append(offspring_ag)        

       
def update():
    global agents, pophawk, popdov, payhawk, paydove, mobhawk, mobdove
    t = 0
    while t < 1 and len(agents) > 0:
        t += 1 / len(agents)
        update_agent()

    pophawk.append(sum([1 for x in agents if x.type == 'hawk']))
    popdove.append(sum([1 for x in agents if x.type == 'dove']))
    payhawk.append(mean([t.bal for t in agents if t.type == 'hawk']))
    paydove.append(mean([t.bal for t in agents if t.type == 'dove']))
    mobhawk.append(mean([t.mov for t in agents if t.type == 'hawk']))
    mobdove.append(mean([t.mov for t in agents if t.type == 'dove']))
    
    
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
