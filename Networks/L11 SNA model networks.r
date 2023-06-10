#Network modelling
library(igraph)

#random networks
#for model with m edges, use type="gnm"
#for model with edge prob p, use type = "gnp"
rand1 <- erdos.renyi.game(10,10, type="gnm") # random nodes, args: nodes, probability or number of links depending on type (gnm/gnp)
plot(rand1, vertex.color="lightblue", 
     main ="random 1", layout=layout.fruchterman.reingold)

#properties
degree(rand1)
degree.distribution(rand1)
plot(degree.distribution(rand1), type = "b") # type b connect the points, !minus one index!
transitivity(rand1)
# bigger network
rand2 <- erdos.renyi.game(500,0.1, type="gnp") # we would expect 500 * 0.1 links per node meaning 50 links on avg
plot(rand2, vertex.color="lightblue", 
     main ="random 2", layout=layout.fruchterman.reingold)
degree(rand2)
degree.distribution(rand2)
plot(degree.distribution(rand2), type = "b") # no node is unconnected
transitivity(rand2)


#diameter
#let's create three sets of 50 random networks of sizes n=100, 1000, 10000

#create vector with repeated values of 100, 1000 and 10000
#it takes a long time to make calculations for 50 networks each
#(as in the slides), so start with only 5 of each size!

n_vect <- rep(c(100,1000,10000),each=5)

#create 5 random networks of each size n and p=10/n-1
#and calculate diameter with a function
g_diam <- sapply(n_vect,function(x)
  diameter(erdos.renyi.game(n=x,p=10/(x-1))))

#create a data frame with each network and its diameter
d_by_n <- data.frame(netsize=as.factor(n_vect), diameter = g_diam)
#mean diameter by network size
aggregate(d_by_n$diameter ~ d_by_n$netsize, FUN=mean)

#diameter by network size (numeric variable, but used as factor)
boxplot(g_diam ~ factor(n_vect))
#in lattice
library(lattice)
bwplot(g_diam ~ factor(n_vect), panel = panel.violin,
       xlab = "Network Size", ylab = "Diameter")

#mean path length
path_l <- sapply(n_vect,function(x)
  mean_distance(erdos.renyi.game(n=x,p=10/(x-1))))
d_by_n$path_length <- path_l
aggregate(d_by_n$path_length ~ d_by_n$netsize, FUN=mean)
boxplot(path_l ~ factor(n_vect))
bwplot(path_l ~ factor(n_vect), panel = panel.violin,
       xlab = "Network Size", ylab = "Mean Path Length", col="orange")

#mean transitivity
trans_l <- sapply(n_vect,function(x)
  transitivity(erdos.renyi.game(n=x,p=10/(x-1))))
d_by_n$transitivity <- trans_l
aggregate(d_by_n$transitivity ~ d_by_n$netsize, FUN=mean)
boxplot(trans_l ~ factor(n_vect))
bwplot(trans_l ~ factor(n_vect), panel = panel.violin,
       xlab = "Network Size", ylab = "Transitivity", col="green")

#Small-world networks
#use help for definitions of dim, size, nei, and p
#always use dim = 1
#nei is number of neighbours on each side, so nei=2 means four neighbours
g1 <- watts.strogatz.game(dim=1, size=20, nei=2, p=0) # these are rewiring probabilities
g2 <- watts.strogatz.game(dim=1, size=20, nei=2, p=.05)
g3 <- watts.strogatz.game(dim=1, size=20, nei=2, p=.20)
g4 <- watts.strogatz.game(dim=1, size=20, nei=2, p=1)

# transititvity
transitivity(g1)
transitivity(g2)
transitivity(g3)
transitivity(g4)

# example with other network
g100 <- watts.strogatz.game(dim=1, size = 100, nei = 2, p = 0) # in networks we only specity neighbours == number of degrees per side, is only a property of regular networks
# explore effect of neighbours and rewiring
for (nei in c(2, 5, 50)){
  for (p in c(0, 0.01, 0.05, 0.3)){
    g100 <- watts.strogatz.game(dim=1, size = 100, nei = nei, p = p)
    print(paste("ne:", nei, "p", p, sep = "_"))
    print(paste("dia:", diameter(g100)))
    print(paste("mean_path:", mean_distance(g100))) # avg path lentgh
    print(paste("transitivity", transitivity(g100))) # all open and closed triplets
  }
}

diameter(g100)
mean_distance(g100) # avg path lentgh
transitivity(g100) # all open and closed triplets
transitivity(g100, type= "local") # for each point 


#change network names g1 g2 etc to plot all sims
plot(g1,vertex.label=NA,layout=layout_in_circle,
     main=expression(paste(italic(p)," = 0")))
#try removing layout cirlce and plotting again

#simulation of SWN path length  
p_vect <- rep(1:30,each=10)
g_diam <- sapply(p_vect,function(x)
  diameter(watts.strogatz.game(dim=1, size=500,
                               nei=2, p=x/200)))
#plot diameter by rewired edges
plot(g_diam~jitter(p_vect,1),col='grey60',
     xlab="Number of Rewired Edges",
     ylab="Diameter")
#add line
smoothingSpline = smooth.spline(p_vect, g_diam, spar=0.35)
lines(smoothingSpline,lwd=1.5)

transitivity(g3)
transitivity(g3, type = "local")

#Exercise model networks
g100 <- watts.strogatz.game(dim=1,size=100,nei=2,p=0)
plot(g100,vertex.label=NA, layout=layout_in_circle, main="g100")
diameter(g100)
mean_distance(g100)
#global for network measure, "local gives transitivity for each node
transitivity(g100, type="global")

#Comparisons between real and model networks
library(intergraph)
library(UserNetR)

?lhds
ilhds <- asIgraph(lhds)
summary(ilhds)
graph.density(ilhds) 
mean(degree(ilhds)) 

#random network, using same n and p = density of ilhds
g_rnd <- erdos.renyi.game(1283,0.0033,type='gnp')

#SWN, using nei = degree(ilhds)/2 = about 2
#let's select a randomisation parameter p = 0.05,
#which is often enought  reduce path length without reducing trnsitivity 
g_swn <- watts.strogatz.game(dim=1,size=1283,nei=2,p=0.05)
graph.density(g_swn)

plot(g_rnd, mode="graph",main="random", vertex.size=2, vertex.label=NA,
     layout=layout_with_kk)
plot(g_swn, mode="graph", main="SWN", vertex.size=2, vertex.label=NA,
     layout=layout_with_kk)
plot(ilhds, mode="graph", main="lhds", vertex.size=2, vertex.label=NA,
     layout=layout_with_kk)

#comparing degree distributions
plot(degree.distribution(ilhds), type="b", main="lhds")
plot(degree.distribution(g_rnd), type="b", main="random")
plot(degree.distribution(g_swn), type="b", main="SWN")

data.frame(network = c("random", "SWM", "ilhds"), 
           diameter = c(diameter(g_rnd), diameter(g_swn), diameter(ilhds)),
           mean_path = c(mean_distance(g_rnd), mean_distance(g_swn), mean_distance(ilhds)),
           transitivity = c(transitivity(g_rnd), transitivity(g_swn), transitivity(ilhds)))



