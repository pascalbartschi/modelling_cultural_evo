#Lecture 7 Intro

#to install UserNetR, you need first to install and load devtools
install.packages("devtools")
library(devtools)
install_github("DougLuke/UserNetR") #package with datasets

#also install
install.packages("statnet.common")
install.packages("sna")
install.packages("igraph")
install.packages("network")

#now load packages
library(statnet.common)
library(sna) 
library(UserNetR)

#Moreno network
class(Moreno)
data("Moreno") #this copies dataset from package into Environment
network.size(Moreno)
#summary gives more info
summary(Moreno) # gives you edgelist
summary(Moreno, print.adj = F) # without edgelist
# possible links:
poss_links <- network.size(Moreno) * (network.size(Moreno) - 1) / 2
# density = 
46 / poss_links
#zoom in and maximise plot window for better visualisation of labels etc 
#function 'plot': with package 'network' 
plot(Moreno, displaylabels = T)
#gplot: need sna and network packages; PREFERABLE 
gplot(Moreno)
gplot(Moreno, gmode="graph", displaylabels = T)

#size
network.size(Moreno)
#density
gden(Moreno)
#components
components(Moreno) # = two subnetworks
#create subnetwork with largest component only
comp1 <- component.largest(Moreno, result="graph") 
gplot(comp1, gmode="graph", displaylabels = T)

summary(comp1)
class(comp1) # it is no subnetwork

#create vector with all path lengths
gd <- geodist(comp1)
#diameter and mean path length
max(gd$gdist)
mean(gd$gdist)

#clustering in percent %
gtrans(Moreno) * 100

#node attributes
Moreno %v% "gender"
Moreno %v% "vertex.names"

#plotting 
plot(Moreno, vertex.col = Moreno %v% "gender", 
     vertex.cex = 3, displaylabels=F)

plot(Moreno, vertex.col = c("red", "blue")[Moreno %v% "gender"], 
     vertex.cex = 2, displaylabels=T)

#Example: creating a network

#create a standard matrix 
adj <- matrix(c(0,1,0,1,0,0,1,0,0,1,0,1,0,1,1,0), 
              nrow=4, byrow=T)
colnames(adj) <- c("A", "B", "C", "D")
rownames(adj) <- c("A", "B", "C", "D")
adj
# Now create a network object using command network()  
# default is directed, so we need to select directed=F!!!
net1 <- network(adj, matrix.type = "adjacency", directed=F)
class(net1)
summary(net1)
plot(net1, displaylabels = T)
gplot(net1, gmode = "digraph", displaylabels = T) # or just graph

# practical 1 
# matrices
sym <- matrix(c(0,1,0,1,0,1,0,1,0), byrow=T, nrow=3)
asym <- matrix(c(0,1,0,0,0,1,0,0,0), byrow=T, nrow=3)

# directed and undirected networks
net_sym_dir <- network(sym, matrix.type ="adjacency", directed = T)
net_sym_undir <- network(sym, matrix.type ="adjacency", directed = F)

net_asym_dir <- network(asym, matrix.type ="adjacency", directed = T)
net_asym_undir <- network(asym, matrix.type ="adjacency", directed = F)

# plotting networks
gplot(net_sym_dir, gmode = "digraph", displaylabels = T) 
gplot(net_sym_undir, gmode = "digraph", displaylabels = T)  

gplot(net_asym_dir, gmode = "digraph", displaylabels = T) 
gplot(net_asym_undir, gmode = "digraph", displaylabels = T)  

degree(net_asym_dir, gmode ="graph")

# undirected makes link A -> B to A <-> B!
# once created undirected we cannot make it directed again


