
#community detection
#modularity 
#mostly with igraph
library(UserNetR)
library(igraph)
library(intergraph)
iMoreno <- asIgraph(Moreno)
V(iMoreno)$gender
plot(iMoreno, vertex.color=V(iMoreno)$gender)
#modularity by gender
modularity(iMoreno, V(iMoreno)$gender)

# for network Bali
iBali <- asIgraph(Bali)
V(iBali)$role
plot(iBali, vertex.color=factor(V(iBali)$role),
     layout = layout_nicely) # 
#modularity by gender
modularity(iBali, factor(V(iBali)$role)) # makes sense: teamwork requires interaction between all roles, modularity mean to have only witin group links


#Facebook
?Facebook
summary(Facebook)
V(Facebook)$group
table(V(Facebook)$group)
plot(Facebook, vertex.color=factor(V(Facebook)$group), 
     vertex.label=V(Facebook)$group)
modularity(Facebook,factor(V(Facebook)$group)) # friends seem to be in the same group
# modularity by sex
plot(Facebook, vertex.color=factor(V(Facebook)$sex), 
     vertex.label=V(Facebook)$sex)
modularity(Facebook,factor(V(Facebook)$sex)) # none of the genders cluster with themselves

#community detection
#you can save the calculation as an object
cw <- cluster_walktrap(iMoreno) # classifies guys in artificial communities with random numbers 1:n
membership(cw)
table(membership(cw))
plot(cw, iMoreno, vertex.label=V(iMoreno)$gender)

#comparing communities to attributes
table(membership(cw), V(iMoreno)$gender)  

# Apply the community analysis to facebook
cw_fb <- cluster_walktrap(Facebook) # classifies guys in artificial communities with random numbers 1:n
membership(cw_fb)
table(membership(cw_fb))
plot(cw_fb, Facebook, vertex.label=factor(V(Facebook)$sex), main = "by sex")
table(membership(cw_fb), V(Facebook)$sex) 
plot(cw_fb, Facebook, vertex.label=factor(V(Facebook)$group), main = "by group")
table(membership(cw_fb), V(Facebook)$group) 

# variable group shows best match with communities detected with walktrap

Facebook <- set_vertex_attr(graph = Facebook, name = "walktrap", value = membership(cw_fb))
# or
V(Facebook)$walktrap <- membership(cw_fb)
modularity(Facebook, factor(V(Facebook)$walktrap))
modularity(Facebook, factor(V(Facebook)$group))
# walktrap maximizes modularity, thus the new groups have higher modularity than attribute groups




#Affiliation networks

#creating incidence matrix
#each vector is a column and character
C1 <- c(1,1,1,0,0,0)
C2 <- c(0,1,1,1,0,0)
C3 <- c(0,0,1,1,1,0)
C4 <- c(0,0,0,0,1,1)
affil <- data.frame(C1,C2,C3,C4)
row.names(affil) <- c("S1","S2","S3","S4","S5","S6")
affil
#analysis using igraph
#create incidence matrix as igraph object
iaffil <- graph.incidence(affil)  # affiliation network gives directions, bipartitie network, unlike adjacency matrix -> func: graph.incidence
get.incidence((iaffil))
class(affil); class(iaffil)
iaffil
V(iaffil)$name
V(iaffil)$type # this means whether element is a characteristic 
plot(iaffil, vertex.color=V(iaffil)$type)

#coordinates for plotting, make the coordinate system
plt.x <- c(rep(2,6),rep(4,4))
plt.y <- c(7:2,6:3)
lay <- as.matrix(cbind(plt.x,plt.y))
plot(iaffil,layout=lay)
#adding more graphics
shapes <- c("circle","square")
colors <- c("blue","red")

#with layout
#you need to color by type+1, since type is logical 
#"FALSE" or "TRUE" and startgs at 0, but we need it to start at 1
plot(iaffil,vertex.color=colors[V(iaffil)$type+1],
     vertex.shape=shapes[V(iaffil)$type+1],
     vertex.size=10,vertex.label.degree=0,
     vertex.label.dist=4,vertex.label.cex=0.9, layout=lay) 

#from edge list into affiliation network 
affedge <- data.frame(rbind(c("S1","C1"),
                            c("S2","C1"),
                            c("S2","C2"),
                            c("S3","C1"),
                            c("S3","C2"),
                            c("S3","C3"),
                            c("S4","C2"),
                            c("S4","C3"),
                            c("S5","C3"),
                            c("S5","C4"),
                            c("S6","C4")))

iaffedge <- graph.data.frame(affedge, directed=FALSE)
#igraph does not know yet this is a bipartite network
iaffedge
V(iaffedge)$type
#to make it a bipartite network, we use name attribute
V(iaffedge)$name

#we use %in% to test if name of nodes are in column 2 
# of affedge dataframe; only C1 C2 etc will be
affedge
#therefore, new variable "type" has logical information  
V(iaffedge)$type <- V(iaffedge)$name %in% affedge[,2] # %in% checks whether in columns, boolean return

V(iaffedge)$type

#now affedge is UN-N, undirected and bipartite 
summary(iaffedge)

#create file with the TWO projection: S network, C network
bip.affedge <- bipartite.projection(iaffedge)
bip.affedge
#now create projection 1 or subject network
p.sub <- bip.affedge$proj1 # this is a network of subjects (Sx)
get.adjacency(p.sub, sparse=F)
#matrix of weights
get.adjacency(p.sub, sparse=F, attr="weight")

#compare densities of projections etc
graph.density(bip.affedge$proj1)
graph.density(bip.affedge$proj2)

