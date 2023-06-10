#Lecture 8 Intro II

#Example: network from edgelist
library(sna)
edge2 <- matrix(c("A","B","A","C","A","G","C","D","C","F","E","F","E","G"),
                byrow = T, nrow = 7)
edge2
net2 <- network(edge2, matrix.type = "edgelist", directed=F) # type edgelist or adjencency matrix
summary(net2)

#note: to recode nodes (not necessary in this case), enter new names 
#in the same order as in the original edgelist; 
#for example, to recode letters as numbers:
#network.vertex.names(net2) <- c("1","2","3","4","5","6","7")
gplot(net2, gmode = "graph", displaylabels = T)

#converting between adjacency matrix and edge list
as.matrix(net2)
as.matrix(net2, matrix.type = "edgelist")
#to create an edgelist file from a network
edge3 <- data.frame(as.matrix(net2, matrix.type = "edgelist"))
edge3

#node attributes
#gender
set.vertex.attribute(net2, "gender", c("F", "F", "M","F", "M", "M", "M"))
summary(net2)
#to list attributes 
get.vertex.attribute(net2, "gender")
net2 %v% "gender"

#node degree
#to add degree in undirected network, add gmode="graph" 
#otherwise, function will add up AB and BA and double degree!
degree(net2, gmode="graph")
degree(net2, gmode="digraph")

net2 %v% "degrees" <- degree(net2, gmode="graph")  # gmode is even used for analysis
list.vertex.attributes(net2)
summary(net2)
net2 %v% "degrees"

#edge attributes
#weights
adj4 <- matrix(c(0,10,0,5,0,0,6,0,0,1,1,1,0,8,1,0), 
               byrow=T, nrow=4)
colnames(adj4) <- c("A", "B", "C", "D")
rownames(adj4) <- c("A", "B", "C", "D")
adj4
net4 <- network(adj4, matrix.type = "adjacency", 
                ignore.eval=F, names.eval="weights") # ignore eval means to weight the values not just 0, 1
summary(net4)

#to see adjacency matrix
as.sociomatrix(net4)
#to see weight matrix
as.sociomatrix(net4, "weights")

#plotting with weights
gplot(net4, gmode = "graph", vertex.cex=2, # size of each vertex
      vertex.col="red", displaylabels=T,   # color of each vertex
      edge.lwd = net4 %e% "weights")       # linewidth of edge
list.edge.attributes(net4)
get.edge.attribute(net4, "weights")
net4 %e% "weights"

#creating weighted network from edge list
#after importing from Excel
edgelist1 <- read.csv("Exercises/edgelist1.csv")

#aggregating rows
edge6 <- as.network(aggregate(list(weights=rep(1,nrow(edgelist1))), edgelist1, length))
class(edge6)

#creating weighted network; notice matrix type
net.weights <- network(edge6, matrix.type = "edgelist", directed=F,
                       ignore.eval = FALSE, names.eval="weights")
summary(net.weights)
get.edge.attribute(net.weights, "weights")

#see node attributes
list.vertex.attributes(net.weights)
#see edge attributes
list.edge.attributes(net.weights)

#see edge weights
net.weights %e% "weights"
as.sociomatrix(net.weights, "weights")
as.matrix(net.weights, matrix.type="edgelist")

# plot
gplot(net.weights, gmode = "graph", vertex.cex=2, # size of each vertex
      vertex.col="red", displaylabels=T,   # color of each vertex
      edge.lwd = 5 * (net.weights %e% "weights"))  

#converting between edgelist and adjacency
adj4
adj4 <- symmetrize(adj4, return.as.edgelist = T)
adj4 <- symmetrize(adj4, return.as.edgelist = F)

#filtering by gender
#net2 has gender info
net2
gplot(net2, gmode = "graph", displaylabels=T)
#inducedSubgraph to filter, 'which' to define selected values
net2males <- get.inducedSubgraph(net2, which(net2 %v% "gender" == "M"))
summary(net2males)
#new adjacency matrix only for males
net2males[,]
gplot(net2males, gmode="graph", displaylabels = T)

#filter by degree
net2 %v% "degrees"
net2deg <- get.inducedSubgraph(net2, which(net2 %v% "degrees" > 1))
gplot(net2deg, gmode = "graph", displaylabels = T)

#removing isolates
class(ICTS_G10)
summary(ICTS_G10, print.adj=F)
plot(ICTS_G10)
components(ICTS_G10)

# list isolates
isolates(ICTS_G10)
# count isolates
length(isolates(ICTS_G10))

#create a copy first; delete.vertices cannot create a new object
ICTScoll <- ICTS_G10
class(ICTScoll)
delete.vertices(ICTScoll, isolates(ICTScoll))
plot(ICTScoll)

#Example: filtering by weight
summary(DHHS, print.adj=F)
class(DHHS)
gplot(DHHS, gmode = "graph")
DHHS %e% "collab"
table(DHHS %e% "collab")

#first create new sociomatrix, with collab values only
d.val <- as.sociomatrix(DHHS, "collab")
#now using thresh to filter which edges to show
gplot(d.val, gmode="graph", thresh = 2, displayisolates = F)

#create network in igraph
#you may need code from previous lecture
detach(package:sna)
detach(package:network)
library(igraph)

adj
graph1 <- graph.adjacency(adj, mode="undirected")
graph1
summary(graph1) # summary with less information
edge2
graph2 <- graph.edgelist(edge2, directed = F)
graph2

#to create node and edge attributes in igraph
V(graph1)$name <- c("A", "B", "C", "D") 
E(graph1)$weights <- c(1,1,10,4,5)
mean(E(graph1)$weights)
summary(graph1)

#convert into network
library(intergraph)
graph1 <- asNetwork(graph1)
class(graph1)
graph1 <- asIgraph(graph1)

#back to sna
#unload igraph and reload sna
#Visualisation
plot(Moreno,mode="circle",vertex.cex=1.5,gmode="graph")
plot(Moreno,mode="fruchtermanreingold",vertex.cex=1.5,gmode="graph")
plot(Moreno,mode="random",vertex.cex=1.5,gmode="graph")

#in igraph
detach(package:sna)
library(igraph)
library(intergraph)
#convert Bali to iBali
iBali <- asIgraph(Bali)

plot(iBali, layout=layout_in_circle, main="kawai")
plot(iBali,layout=layout_randomly, main="randomly")
plot(iBali,layout=layout_with_fr, main="force_field_based")

#back to sna, notice now we use file Bali instead of iBali
detach(package:igraph)
library(sna)

#plotting vertices with role as colours
plot(Bali, vertex.col= "role", edge.col="grey50", 
     vertex.cex=1.5, displaylabels=T, label.pos=5)

#node size as degree
#create vector with degrees and use it in parameter vertex.cex
degBali <- degree(Bali, gmode="graph")
gplot(Bali, usearrows = F, vertex.cex=0.2*degBali, displaylabels = T,
      label=Bali %v% "role")

#plot weighted network links with edge width
plot(Bali, usearrows = F, vertex.cex=0.2*degBali, label.pos=5, 
     vertex.col = "slateblue", displaylabels = T, 
     edge.lwd = (Bali %e% "IC")^1.5)

