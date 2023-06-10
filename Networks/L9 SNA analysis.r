#Analysis

#centrality measures
library(sna)
library(UserNetR)
gplot(Bali, gmode= "graph", displaylabels=T, vertex.col="lightblue",
      vertex.cex=1, label.col="black", label.pos=1)
Bali %v% "vertex.names"
degree(Bali, gmode="graph")
mean(degree(Bali, gmode="graph"))
hist(degree(Bali, gmode="graph"), breaks = seq(0, 20, 1))

closeness(Bali, gmode="graph")
mean(closeness(Bali, gmode="graph"))
hist(closeness(Bali, gmode="graph"), breaks = seq(0, 1,0.01))

betweenness(Bali, gmode="graph")

#cutpoints
cutpoints(Bali, mode="graph", return.indicator=T)

# frame for closeness
centrality_Bali <- closeness <- data.frame(name = Bali %v% "vertex.names", 
                                           degree = degree(Bali, gmode = "graph"),
                                           closeness = closeness(Bali, gmode="graph"), 
                                           betweenness = betweenness(Bali, gmode="graph"),
                                           cutpoints = cutpoints(Bali, mode="graph", return.indicator=T))

#colouring cutpoints
#don't forget mode="graph" for undirected graphs
cuts <- cutpoints(Bali,mode="graph", return.indicator=T)
cuts
gplot(Bali, gmode="graph", vertex.col = cuts+2, displaylabels=T, # color schemes vary with adding different integers
      label.pos=3, vertex.cex=0.5, label.cex = 1)

# cutpoints in moreno
sum(cutpoints(Moreno,mode="graph", return.indicator=T)) 
gplot(Moreno, gmode = "graph", vertex.col = cutpoints(Moreno,mode="graph", return.indicator=T) + 2, 
      displaylabels = T, label.pos = 3, vertex.cex = 0.5, label.cex = 1)

#Subgroups
#drawing network using formula
#subgroups often use igraph 
detach(package:sna)
library(igraph)

subs0 <- graph.formula(A-B-C-D,D-E,E-F-G-E)
plot(subs0)
#drawing a larger clique ABCD
subs <- graph.formula(A:B:C:D--A:B:C:D,D-E,E-F-G-E) # : means all connected, -- longer connction
plot(subs)

#now to identify cliques
#size of largest clique
clique.number(subs)
#list cliques of a certain size
cliques(subs, min=clique.number(subs))
#excluding cliques within a clique
maximal.cliques(subs, min=clique.number(subs))
largest.cliques(subs)

# do the same for Moreno
library(intergraph)
iMoreno <- asIgraph(Moreno)
class(iMoreno)

#now to identify cliques
#size of largest clique
clique.number(iMoreno)
#list cliques of a certain size
cliques(iMoreno, min=clique.number(iMoreno))
#excluding cliques within a clique
maximal.cliques(iMoreno, min=3)
largest.cliques(iMoreno)

#k-cores
coreness(subs)
table(coreness(subs))

V(subs)$colour <- coreness(subs) 
plot(subs,vertex.label.cex=0.8, vertex.color=coreness(subs), 
     vertex.label=coreness(subs), gmode="graph")

#k-core: more complex example; always in igraph
library(intergraph)
iDHHS <- asIgraph(DHHS)
summary(iDHHS)
#here we are selecting only collab > 2 (edge property) 
#in igraph, you subset with function subgraph.edges

iDHHS2 <- subgraph.edges(iDHHS,E(iDHHS)[collab > 2])
summary(iDHHS2)
plot(iDHHS2, gmode="graph")

#calculating coreness
coreness <- coreness(iDHHS2) # coreness is connected by each other by at least "coreness"
coreness
table(coreness) # one node has 7 cores, etc
V(iDHHS2)$color <- coreness 
plot(iDHHS2,vertex.col=coreness, vertex.label=coreness)

# same but with DHHS

#calculating coreness
coreness <- coreness(iDHHS)
coreness
table(coreness) # one node has 7 cores, etc
V(iDHHS)$color <- coreness 
plot(iDHHS,vertex.col=coreness, vertex.label=coreness)


