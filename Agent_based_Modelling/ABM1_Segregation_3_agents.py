#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 30 13:20:02 2023

@author: pascal

# Note: run this code in spyder IDE with automatic backend plotting enabled
        in preferences.
"""

from pylab import *
from numba import jit

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
        ag.type = randint(3) # initialize three different agent types
        ag.x = random()
        ag.y = random()
        agents.append(ag)
    
def observe(i):
    global agents
    cla() 
    red = [ag for ag in agents if ag.type == 0]
    blue = [ag for ag in agents if ag.type == 1]
    green = [ag for ag in agents if ag.type == 2]
    plot([ag.x for ag in red], [ag.y for ag in red], 'ro')   # red agent
    plot([ag.x for ag in blue], [ag.y for ag in blue], 'bo') # blue agent
    plot([ag.x for ag in green], [ag.y for ag in green], 'go') # green agent
    title(f"step: {i}")
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
         
 
            
       
initialise()
fig = figure()
ax = fig.add_subplot(1,1,1)
maxsteps = int(1e5)
i = 0
observe(i)

# for i in range(steps):  
for i in range(1, maxsteps):
    
    ax.clear()
    update()
    observe(i)
    pause(0.0001)
    