#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 30 13:12:47 2023

@author: pascal
"""

import random as rd
import pylab as py

n = 100 # number of agents

class agent:
    pass

def initialise():
    """
    Info part comes into this docstring
    """
    global agents, n 
    agents = []
    for i in range(n):
        ag = agent()
        ag.x = rd.uniform(-1,1) # select x and y values: random number between (-1,1)
        ag.y = rd.uniform(-1,1) 
        ag.newx = 0 # # we need to store two positions: current and previous 
        ag.newy = 0
        agents.append(ag)
    
def observe():
    global agents
    py.cla()   
    py.plot([ag.x for ag in agents], [ag.y for ag in agents], 'ro')
    py.axis('image')
    py.axis([-150, 150, -150, 150])
  
def update():
    global agents
    Cx = py.mean([ag.x for ag in agents]) # centre C of swarm in x and y
    Cy = py.mean([ag.y for ag in agents])
    xnoise = py.uniform(-50, 50)
    ynoise = py.uniform(-50, 50)
    
    for ag in agents:
        ag.newx = 2*ag.x - ag.newx + 1.5*(Cx - ag.x)/py.norm(Cx - ag.x)  # acceleration the swarm center
        # 2ag is: current value (=ag) + variation (=ag - agnew) 
        # norm removes minus sign; term is a restoring force
        ag.newy = 2*ag.y - ag.newy + 1.5*(Cy - ag.y)/py.norm(Cy - ag.y) 
        # now we need to update ag.x, that becomes 
        # the calculated ag.new; and then ag.new 
        # becomes the old ag.x (which is stored for next round)
        ag.x, ag.newx = ag.newx, ag.x 
        ag.y, ag.newy = ag.newy, ag.y
        
## automatic window animation in spyder
steps = 1000
initialise()
fig = py.figure()
ax = fig.add_subplot(1,1,1)
   
observe()

for i in range(steps):    

    ax.clear()
    update()
    observe()
    py.pause(0.01)
    
## save animation?
save = False
if save:
    import progressbar
    from matplotlib import animation
    import datetime
    
    animation_name = f"Simulations/Flocking_{n}n_{steps}steps"
    initialise()
    fig = py.figure()
    ax = py.axes()
    observe()
    
    bar = progressbar.ProgressBar(max_value = steps)


    def animate(i):        
        
        ax.clear()
        update()
        observe()
        bar.update(i+1)
        # print(f"step: {i}")
        #plt.colorbar()

    anim = animation.FuncAnimation(fig, animate, frames=steps, interval=200)

    # if time stamp from time.time(): use datetime.fromtimestamp(time.time()).strftime(...)
    sim_date = datetime.datetime.now().strftime("%d-%m-%Y_%H:%M:%S")

    anim.save(animation_name + sim_date + ".mp4", fps=30)