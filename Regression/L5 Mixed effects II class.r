#group comparisons
kruskal.test(rats$Glycogen ~ rats$Treatment)

avrat <- tapply(rats$Glycogen, list(rats$Treatment,rats$Rat), mean)
avrat
treat <- gl(3,1,length=6)#creating treatment levels
kruskal.test(as.vector(avrat) ~ treat)

#rat example
#nested levels
rat <- rats$Treatment:rats$Rat
liver <- rats$Treatment:rats$Rat:rats$Liver

#model
library(lme4)
modelrats <- lmer(Glycogen ~ Treatment+(1|rat)+(1|liver), data=rats)
summary(modelrats)
rats.null <- lmer(Glycogen ~ (1|rat)+(1|liver), data=rats)
anova(modelrats, rats.null)

#releveling
rats$Treatment <- relevel(rats$Treatment, ref = "2")

#variance components analysis
vars <- c(14.167,36.065,21.167)
100*vars/sum(vars)

#Multilevel modelling
attach(childfull) # wo dont need to write dollar to acces columns
# first do t.test to check
tapply(childfull$response, childfull$gender, hist)
t.test(childfull$response ~childfull$gender)  # says that gender doesn't make a difference


#define multilevel nested structure
d <- town:district
s <- town:district:street
h <- town:district:street:house

#no fixed effect and four nested random effects:
schools.null <- lmer(response ~ (1|town)+(1|d)+(1|s)+(1|h))
summary(schools.null) # most variation is caused by varation in district, intercept is just the average of the data

#one fixed effect (gender) and four nested random effects:
schools.full <- lmer(response~gender+(1|town)+(1|d)+(1|s)+(1|h)) # we can now compare gender because we are able to expain noise by ranaom effects
summary(schools.full)

#significance test
anova(schools.null, schools.full)

#variance components analysis
v <- c(4.0817, 15.6746, 168.3500, 36.9757, 36.2406)
vc <- v/sum(v)
vc

#plotting
hist(response[town=="Coventry"],main="Coventry",breaks=seq(40,150,5),
     xlab="response")
plot(response~district,subset=(town=="Coventry"),main="Coventry")

# include town as fixed factor
town.full <- lmer(response ~ town + (1|d)+(1|s)+(1|h), data = childfull)
town.null <- lmer(response ~ (1|d)+(1|s)+(1|h), data = childfull)
anova(town.full, town.null)

#generalised mixed effects
#logistic model

library("MASS") # where file bacteria is

#bacterial infection
head(bacteria, 10)
table(bacteria$y,bacteria$ap)

#proportion test 
prop.test(c(93,84),c(124,96))

#logistic regression not controlling for pseudoreplication
inf <- glm(y ~ ap, binomial, data=bacteria)
summary(inf)
step(inf)
summary(step(inf))

#ID as random effect on intercept
infection <- glmer(y ~ ap + (1 |ID), family=binomial, data=bacteria)
summary(infection)

#significance
infection.null <- glmer(y ~ (1|ID),family=binomial, data=bacteria)
anova(infection, infection.null)

#ID as random effect on intercept and slope
infection.slope <- glmer(y ~ ap + (1 + ap |ID), family=binomial, data=bacteria)
summary(infection.slope)

#significance
infection.null <- glmer(y ~ (1|ID),family=binomial, data=bacteria)
anova(infection.slope, infection.null)

