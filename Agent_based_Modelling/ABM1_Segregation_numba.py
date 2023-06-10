#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Apr  5 15:41:30 2023

@author: pascal
"""

import numpy as np
from numba import jit
import matplotlib.pyplot as plt
import time

# params

n = 1000 # number of agents
r = 0.1 # neighbourhood radius
thresh = (0.5, 0.5, 0.5) # threshold for moving # the lower the thresh the higher the tolerance

# initialize the agents
# axy = np.random.uniform(0, 1 , size = (n, 2))
# atype  = np.random.randint(0, 3, size = n)
# xy_list = [axy.copy()]

@jit(nopython = True)
def update(axy, atype):
    # choose random agent
    i = np.random.randint(0, n-1)
    # neighbour defined within given radius
    mask_nb = np.where(((axy[i, 0] - axy[:, 0]) ** 2 + (axy[i, 1] - axy[:, 1]) ** 2) < r**2)[0]
    # if roreigner ratio in neighbours> thresh
    q = (len(np.where(atype[i] == atype[mask_nb])[0])-1) / len(mask_nb)
    # print(q)
    if q < thresh[atype[i]]:
        axy[i] = np.random.uniform(0, 1 ,size=2)
    
    # xy_list.append(axy)
    return axy
    
@jit(nopython = True)    
def sim(steps):
    
    axy = np.random.uniform(0, 1 , size = (n, 2))
    atype  = np.random.randint(0, 3, size = n)
    xy_list = [axy.copy()]
    
    for i in range(steps):
        axy = update(axy, atype)
        # xy_list.append(axy.copy())
        
    return axy, atype

import time

start = time.time()
steps = int(1e7)
axy, atype = sim(steps)
stop = time.time()
print(f"sim time: {stop-start} for {steps} steps")


# plotting after x steps
fig, ax = plt.subplots(1, 1)
ax.scatter(x = axy[:, 0],
            y = axy[:, 1],
            c = atype)

label = f"n{n}_r{r}_thresh{thresh}_steps{steps}"
ax.set_title(label.replace("_", " "))


plt.savefig(label + ".png")
plt.show()

print(label + ".png")




## unhastag for animation in spyder
# fig, ax = plt.subplots(1, 1)
# maxsteps = int(1e5)
# i = 0


# axy = np.random.uniform(0, 1 , size = (n, 2))
# atype  = np.random.randint(0, 3, size = n)
# # for i in range(steps):  
# for i in range(1, steps):
    
#     ax.clear()
#     axy = update(axy, atype)
#     ax.scatter(x = axy[:, 0],
#                 y = axy[:, 1],
#                 c = atype)
#     ax.set_title(f"step: {i}")
#     plt.pause(0.0001)
         
