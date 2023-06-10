#example: pitch
#load L3 workspace file

t.test(pitch$frequency ~ pitch$attitude)
wilcox.test(pitch$frequency ~ pitch$attitude)

#random intercepts
library(lme4)
polite <- lmer(frequency ~ attitude + (1|subject) + (1|scenario), data=pitch)
summary(polite)
coef(polite) # we see that there is no effect on
polite2 <- lmer(frequency ~ attitude + gender
               + (1|subject) + (1|scenario), data=pitch)
summary(polite2)
coef(polite2)
#significance test for attribute
polite.null <- lmer(frequency ~ (1|subject) + (1|scenario),
                    data=pitch)
anova(polite.null, polite, test ="chisq")

#significance test for gender
anova(polite2, polite, test ="chisq")

#random slopes model
pol.slope <- lmer(frequency~attitude+gender+(1+attitude|subject)  # random variation of attitude as function of subject
                    +(1+attitude|scenario),data=pitch)
summary(pol.slope)
coef(pol.slope)

#to control for random slopes of attitude and gender
pol.slopes2 <- lmer(frequency~attitude+gender+(1+attitude+gender|subject)
  +(1+attitude+gender|scenario),data=pitch)
summary(pol.slopes2)
coef(pol.slopes2)

#mixed effects linear regression
plot(size ~ N,pch=rep(16:19,each=40),col=farm, data=farms)
summary(lm(size ~ N, data=farms))
# actually there is pseudo replication, we average five points per farm
mean.size <- data.frame(tapply(farms$size, farms$farm, mean))
mean.N <- data.frame(tapply(farms$N, farms$farm, mean))
plot(mean.size$tapply.farms.size..farms.farm..mean.
     ~mean.N$tapply.farms.N..farms.farm..mean., pch=16, cex=1.3)
summary(lm(mean.size$tapply.farms.size..farms.farm..mean.~mean.N$tapply.farms.N..farms.farm..mean.))

# separate regression lines -> very low sample sizes per regression
linear.models <- lmList(size~N|farm,data=farms)
summary(linear.models)
#random intercepts only
farm.int <- lmer(size ~ N+(1|farm), data=farms)
summary(farm.int)
coef(farm.int)
farm.null <- lmer(size ~ (1|farm), data=farms)
anova(farm.int, farm.null)

#random slopes
farm.slope <- lmer(size~ N + (1+N|farm),data=farms)
summary(farm.slope)
coef(farm.slope)

#plotting
plot(size ~ N,pch=rep(16:19,each=40),col=farm, data=farms)
abline(85.82438, 0.69876, lwd=2)
library(lattice)
xyplot(size ~ N, data=farms, type=c("p","r"),
       col=1:24, pch=16, cex=1.5, groups=farm,xlab="N", ylab="plant size")

#quiz plots
library(lattice)
###
#simple regression
plot(ysimp~xsimp, pch=16, data=simp)
summary(lm(ysimp~xsimp, data=simp))
abline(lm(ysimp~xsimp, data=simp))

#but the points are not independent; they come from five species
#in each species, slope is positive
xyplot(ysimp ~ xsimp, groups=group,data=simp, pch=16)
xyplot(ysimp ~ xsimp, groups=group,data=simp, pch=16, type=c("p", "r"))
lmList(ysimp~xsimp|group, data=simp)

#mixed effects models
#random intercept
simp.model1 <- lmer(ysimp~xsimp + (1|group), data=simp)
summary(simp.model1) 
coef(simp.model1)
#plot
plot(ysimp~xsimp, col=group, pch=16, data=simp)
abline(a=2.33352, b=-0.25367, lty = 2)

#random intercept and slope
simp.model2 <- lmer(ysimp~xsimp + (1+xsimp|group), data=simp)
summary(simp.model2) 
coef(simp.model2)
abline(a=1.0691, b=-0.1468, lty =3, lwd =3)

