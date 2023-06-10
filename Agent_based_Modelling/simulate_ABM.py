#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 30 11:21:16 2023

@author: pascal
"""
import matplotlib.pyplot as plt
from matplotlib import animation
import progressbar
import datetime




def window_animation(steps, initialise, update, observe):
    
    initialise()
    fig = plt.figure()
    ax = fig.add_subplot(1,1,1)
   
    observe()
    
    for i in range(steps):    

        ax.clear()
        update()
        observe()
        plt.pause(0.01)
        
        
def mp4_animation(steps,animation_name, initialise, update, observe):
    
    initialise()
    fig = plt.figure()
    ax = plt.axes()
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