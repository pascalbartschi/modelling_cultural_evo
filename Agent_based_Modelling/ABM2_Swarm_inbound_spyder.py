#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 30 13:58:45 2023

@author: pascal
"""

import random as rd
import pylab as py

n = 150 # number of agents

class agent:
    pass

def initialise():
    global agents    
    agents = []
    for i in range(n):
        ag = agent()
        ag.x = rd.uniform(-1, 1) 
        ag.y = rd.uniform(-1, 1) 
        #ag.randx = rd.uniform(-1,1)
        #ag.randy = rd.uniform(-1, 1)*(1**2 - ag.randx**2)**0.5
        ag.newx = 0 # we need to store two positions: current and previous
        ag.newy = 0
        agents.append(ag)
   
def observe():
    global agents
    py.cla()   
    py.plot([ag.x for ag in agents], [ag.y for ag in agents], 'bo')
    #red = [ag for ag in agents if ag.type == 0]
    #blue = [ag for ag in agents if ag.type == 1]
    #py.plot([ag.x for ag in red], [ag.y for ag in red], 'go', markersize=3)
    #py.plot([ag.x for ag in blue], [ag.y for ag in blue], 'bo', markersize=3)    
    py.axis('image')
    py.axis([-50, 50, -50, 50])
  
def update():
    global agents
    Cx = py.mean([ag.x for ag in agents]) #+ 0.1*rd.gauss(0,1)
    Cy = py.mean([ag.y for ag in agents]) #+ 0.1*rd.gauss(0,1)
    xnoise = py.uniform(-50, 50) #picks random point in grid
    ynoise = py.uniform(-50, 50)
    
    for ag in agents:
        #neighbours = [nb for nb in agents
        #             if (ag.x - nb.x)**2 + (ag.y - nb.y)**2 < r**2 and nb != ag]
        #cx = py.mean([ag.x for nb in neighbours])
        #cy = py.mean([ag.y for nb in neighbours])
        #if ag.type == 1:
        ag.newx = 2*ag.x - ag.newx \
            + 0.2*(Cx - ag.x)/py.norm(Cx - ag.x) \
            + 0.1*(xnoise-ag.x)/py.norm(xnoise-ag.x)    
        ag.newy = 2*ag.y - ag.newy \
            + 0.2*(Cy - ag.y)/py.norm(Cy - ag.y) \
            + 0.1*(ynoise-ag.y)/py.norm(ynoise-ag.y)    
                
        #else:
         #   ag.newx = 2*ag.x - ag.newx + 0.2*(Cx - ag.x)/py.norm(Cx - ag.x) 
          #  ag.newy = 2*ag.y - ag.newy + 0.2*(Cy - ag.y)/py.norm(Cy - ag.y) 
        ag.x, ag.newx = ag.newx, ag.x
        ag.y, ag.newy = ag.newy, ag.y
        

steps = 100   
flag = True
k = 0
initialise()
fig = py.figure()
# ax = add_subplot(1,2,1)
observe()

while flag: 
    k += 1
    update()
    if k%1 == 0:
        # ax.clear()
        observe()
        py.annotate(f"step: {k}", xy = (50, 50))
        py.pause(0.01)