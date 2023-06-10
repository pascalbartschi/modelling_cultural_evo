######################################
# PROJECT 1: TRANSMISSION OF KNOWLEDGE
######################################
# rm(list() = ls)
library(tidyverse)
library(readr)

setwd("~/Library/CloudStorage/OneDrive-Personal/Dokumente/BSc_UZH/UZH_23FS/BIO206/Reports/1")
know <- read.csv("plant_knowledge.csv", sep = ",")
people <- read.csv("plant_participants.csv", sep =",")

 # first get insight into dataset
glimpse(know)
glimpse(people)

# create a unique list of columns to obtain an overview
cat_people <- list("camp" = unique(people$camp),
                  "sex" = unique(people$sex),
                  "age" = unique(people$age),
                  "born" = unique(people$born),
                  "born_cluster" = unique(people$born_cluster),
                  "learned" = unique(people$learned))

# create dyads
dyads = data.frame(t(combn(people$ID, 2)))
# dim of resulting frame
no_dyads = length(people$ID)* (length(people$ID)-1)/2
no_plants = ncol(know) - 1
# add dyad names
dyads$dyad_ID = paste(dyads$X1, dyads$X2, sep ="_")
colnames(dyads) = c("ID1", "ID2", "dyad_ID") 

# merge with plant knowledge
dyads_people <- merge(dyads, people, by.x = "ID2", by.y = "ID")
dyads_people <- merge(dyads_people, people ,by.x = "ID1", by.y = "ID")


dyads_people$dyadsex <- paste0(pmin(dyads_people$sex.x, dyads_people$sex.y),
                               pmax(dyads_people$sex.x, dyads_people$sex.y))

dyads_people$samesex <- ifelse(dyads_people$dyadsex == "FM", 1, 0) # ifelse to see where they match

know <- know %>% gather("plant", "know", -ID)   # switch from wide to long format



dyads_merged <- merge(dyads_people, know, by.x = "ID1", by.y = "ID")
dyads_merged <- merge(dyads_merged, know, by.x = c("ID2", "plant"), by.y = c("ID", "plant"))

print("Check dimension of frame:", nrow(dyads_merged) == no_dyads * no_plants)


dyads_merged <- dyads_merged %>% 
  select(c(3, 1, 4, 5, 11, 6, 12, 18, 17, 7, 13, 8, 14, 9, 15, 19, 20)) %>%
  rename_with(~gsub(".x","1", .x, fixed = T)) %>%
  rename_with(~gsub(".y","2", .x, fixed = T))

write.csv(dyads_merged, "dyads_plants_merged.csv")
  

    
