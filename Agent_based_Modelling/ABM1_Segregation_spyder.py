#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 30 13:20:02 2023

@author: pascal
"""

from pylab import *

# Parameters
n = 1000 # number of agents
r = 0.1 # neighbourhood radius
thresh = 0.65 # threshold for moving

class agent:
    pass

def initialise():
    global agents 
    agents = [] 
    for i in range(n):
        ag = agent()
        ag.type = randint(2)
        ag.x = random()
        ag.y = random()
        agents.append(ag)
    
def observe():
    global agents
    cla() 
    red = [ag for ag in agents if ag.type == 0]
    blue = [ag for ag in agents if ag.type == 1]
    plot([ag.x for ag in red], [ag.y for ag in red], 'ro')
    plot([ag.x for ag in blue], [ag.y for ag in blue], 'bo')
    axis('image')
    axis([0, 1, 0, 1])

def update():
    global agents
    ag = choice(agents)
    neighbours = [nb for nb in agents
                 if nb != ag and (ag.x - nb.x)**2 + (ag.y - nb.y)**2 < r**2]
    if len(neighbours) > 0:
        q = len([nb for nb in neighbours if nb.type == ag.type]) \
            / float(len(neighbours))
        if q < thresh:
         ag.x, ag.y = random(), random()
         
 
            
steps = 10000       
initialise()
fig = figure()
ax = fig.add_subplot(1,1,1)
   
observe()

for i in range(steps):    

    ax.clear()
    update()
    observe()
    pause(0.01)