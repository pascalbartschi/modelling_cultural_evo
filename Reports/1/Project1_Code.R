######################################
# PROJECT 1
######################################
 # clean
rm(list = ls())
# libraries
library(tidyverse)
library(ggplot2)

# read in data
setwd("~/Library/CloudStorage/OneDrive-Personal/Dokumente/BSc_UZH/UZH_23FS/BIO206/Reports/1")
people <- read.csv("plant_participants.csv")
know <- read.csv("plant_knowledge.csv")

# 1. Plant knowledge file

## a)
know <- read.csv("plant_knowledge.csv")
print(paste("Subjects: ", nrow(know)))
print(paste("Plants: ", ncol(know) - 1))


# b) 
sum_know_plant <- colSums(know[,-1])
avg_know_plant <- mean(sum_know_plant)
# maybe line with mean
hist(sum_know_plant)
ggplot(mapping = aes(x = sum_know_plant)) + 
  geom_histogram(bins = 8)

# c)
sum_know_people <- rowSums(know[,-1])
names(sum_know_people) <- know$ID
avg_know_people<- mean(sum_know_people)
hist(sum_know_people)

## Exercise 2
# a) 
age_hist <- table(people$age) # use count for digits and table for factors

# b)
count_pre_20 <- people %>% filter(age == "05-10" | age == "10-15") %>% nrow(.)
fraction_pre_20 <- count_pre_20 / nrow(people)

# c) 
count_males <- people %>% filter(sex == "M") %>% nrow(.)
count_females <-  people %>% filter(sex == "M") %>% nrow(.)

## Exercise 3
# first merge to a dyad frame

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
  select(c(3, 1, 4, 5, 11, 6, 12, 18, 17, 7, 13, 8, 14, 9, 15, 2, 19, 20, 10, 16)) %>%
  rename_with(~gsub(".x","1", .x, fixed = T)) %>%
  rename_with(~gsub(".y","2", .x, fixed = T))

# a)
table(dyads_merged$dyadsex)

# b)
# young
dyads_merged %>% 
  filter((age1 == "05-10" & age2 == "05-10") | 
          (age1 == "05-10" & age2 == "10-15") |
          (age1 == "10-15" & age2 == "05-10") |
          (age1 == "10-15" & age2 == "10-15")) %>%
  nrow(.)
  
# old
dyads_merged %>%
  filter(age1 == "60-80" & age2 == "60-80") %>%
  nrow(.)

# c) born
dyads_merged$sameborn <- ifelse(dyads_merged$born1 == dyads_merged$born2 & 
                                  !is.na(dyads_merged$born1) & 
                                  !is.na(dyads_merged$born2), 1, 0)

dyads_merged$diffborn <- ifelse(dyads_merged$born1 != dyads_merged$born2 &  
                                  !is.na(dyads_merged$born1) & 
                                  !is.na(dyads_merged$born2), 1, 0)
# omit nas otherwise na comparison
sum(dyads_merged$sameborn)
sum(dyads_merged$diffborn)

# d) camp
samecamp <- ifelse(dyads_merged$camp1 == dyads_merged$camp2 & 
                    !is.na(dyads_merged$camp1) & 
                    !is.na(dyads_merged$camp2), 1, 0)

diffcamp <- ifelse(dyads_merged$camp1 != dyads_merged$camp2 &  
                    !is.na(dyads_merged$camp1) & 
                    !is.na(dyads_merged$camp2), 1, 0)
# omit nas otherwise na comparison
sum(samecamp)
sum(diffcamp)
  
## Exercise 4: Total knowledge score: kruskal wallis if not N and ANOVA if normally distributed

dyads_merged$dyadknow <- ifelse(dyads_merged$know1 == 1 & dyads_merged$know2 == 1, 1, 0)

# a) age
dyads_merged$dyadagelevels <- ifelse((dyads_merged$age1 == "05-10" & dyads_merged$age2 == "05-10") | 
                                     (dyads_merged$age1 == "05-10" & dyads_merged$age2 == "10-15") |
                                     (dyads_merged$age1 == "10-15" & dyads_merged$age2 == "05-10") |
                                     (dyads_merged$age1 == "10-15" & dyads_merged$age2 == "10-15"), 
                                   "young", 
                                   ifelse(dyads_merged$age1 == "60-80" & dyads_merged$age2 == "60-80", 
                                          "old", ifelse(is.na(dyads_merged$age1) | is.na(dyads_merged$age2), 
                                                        "others", "others")))

know_age <- dyads_merged %>% 
  filter(!is.na(dyadagelevels)) %>%
  group_by(dyad_ID, dyadagelevels) %>%
  summarise(sum_know = sum(dyadknow), n= n()) # %>%
  # group_by(dyadagelevels) %>%
  # summarise(mean_know = mean(sum_know))

ggplot() +
  geom_boxplot(data = know_age, mapping = aes(x = dyadagelevels, y = sum_know, colour = dyadagelevels)) + 
  labs(x = "dyad age level", y = "dyad plant knowledge", 
       title = "boxplot of plant knowledge by age") +
  theme_bw()


# b) sex

# how do I get rid of the NAs?
know_sex <- dyads_merged %>% 
  filter(dyadsex != "NANA") %>%
  group_by(dyad_ID, dyadsex) %>%
  summarise(sum_know = sum(dyadknow), n= n())

ggplot() +
  geom_boxplot(data = know_sex, mapping = aes(x = dyadsex, y = sum_know, colour = dyadsex)) + 
  labs(x = "dyad sex", y = "dyad plant knowledge", 
       title = "boxplot of plant knowledge by sex") +
  theme_bw()

# c) camp
dyads_merged$dyadcamp <- ifelse(dyads_merged$camp1 == dyads_merged$camp2, "same", "different")

# how do I get rid of the NAs?
know_camp <- dyads_merged %>% 
  filter(!is.na(dyadcamp)) %>%
  group_by(dyad_ID, dyadcamp) %>%
  summarise(sum_know = sum(dyadknow), n= n()) # %>%
# group_by(dyadagelevels) %>%
# summarise(mean_know = mean(sum_know))

ggplot() +
  geom_boxplot(data = know_camp, mapping = aes(x = dyadcamp, y = sum_know, colour = dyadcamp)) + 
  labs(x = "dyad camp", y = "dyad plant knowledge", 
       title = "boxplot of plant knowledge by camp") + 
  theme_bw()


## Exercise  5
# column shared knowledge is called dyadknow
# add convertion function
odds2P <- function (odds){
  return (odds / (1 + odds))
}
# a) age

simplem_logreg_age <- glm(dyadknow ~ dyadagelevels, binomial, data = dyads_merged)
summary(simplem_logreg_age)
# coeficicents of model
coef_age <- coef(simplem_logreg_age) ; names(coef_age) <- c("baseline", "others", "young")
# odds baseline: P(know) / P(not know)
odds_base <- exp(coef_age["baseline"])
# odds ratios of who is more likely to know plant vs baseline
exp(coef_age["others"]) # others:old
exp(coef_age["young"]) # young:old
# odds exposure groups: P(know) / P(not know)
odds_others <- exp(coef_age["others"] + coef_age["baseline"])
odds_young <- exp(coef_age["young"] + coef_age["baseline"])
# probalities that groups knows a plant
odds2P(odds_others)
odds2P(odds_young)
odds2P(odds_base)

# b) sex

simplem_logreg_sex <- glm(dyadknow ~ dyadsex, binomial, data = dyads_merged)
summary(simplem_logreg_sex)

coef_sex <- coef(simplem_logreg_sex)[1:3] ; names(coef_sex) <- c("baseline", "FM", "MM")
# odds baseline: P(know) / P(not know)
odds_FF <- exp(coef_sex["baseline"])
# odds ratios of who is more likely to know plant vs baseline
exp(coef_sex["FM"]) # FM:FF
exp(coef_sex["MM"]) # MM:FF
# odds exposure groups: P(know) / P(not know)
odds_FM <- exp(coef_sex["FM"] + coef_sex["baseline"])
odds_MM <- exp(coef_sex["MM"] + coef_sex["baseline"])
# probalities that groups knows a plant
odds2P(odds_FM)
odds2P(odds_MM)
odds2P(odds_FF)

# c) camp

simplem_logreg_camp <- glm(dyadknow ~ dyadcamp, binomial, data = dyads_merged)
summary(simplem_logreg_camp)

coef_camp <- coef(simplem_logreg_camp) ; names(coef_camp) <- c("baseline", "same")
# odds baseline: P(know) / P(not know)
odds_diff <- exp(coef_camp["baseline"])
# odds ratios of who is more likely to know plant vs baseline
exp(coef_camp["same"]) # same:diff
# odds exposure groups: P(know) / P(not know)
odds_same <- exp(coef_camp["same"] + coef_camp["baseline"])
# probalities that groups knows a plant
odds2P(odds_diff)
odds2P(odds_same)

# d) multiplicative

simplem_logreg_agexsex <- glm(dyadknow ~ dyadagelevels * dyadsex, binomial, data = dyads_merged)
summary(simplem_logreg_agexsex)




## Exercise 6
library(lme4)
# a) included effect: learned from the same source
dyads_merged$samelearned <- ifelse(dyads_merged$learned1 == dyads_merged$learned2, 1, 0)
# dyads_merged$sameborn <- ifelse(dyads_merged$born1 == dyads_merged$born2, 1, 0)
# variance components analysis?

# b) age
mixedm_logreg_age <- glmer(dyadknow ~ dyadagelevels + (1|samelearned), family = binomial, data = dyads_merged)
summary(mixedm_logreg_age)

# c) sex
mixedm_logreg_sex <- glmer(dyadknow ~ dyadsex + (1|samelearned), family = binomial, data = dyads_merged)
summary(mixedm_logreg_sex)

# d) camp
mixedm_logreg_camp <- glmer(dyadknow ~ dyadcamp + (1|samelearned), family = binomial, data = dyads_merged)
summary(mixedm_logreg_camp)

# multiplicative
mixedm_logreg_agexsex <- glmer(dyadknow ~ dyadagelevels * dyadsex + (1|samelearned), family = binomial, data = dyads_merged)
summary(mixedm_logreg_agexsex)






