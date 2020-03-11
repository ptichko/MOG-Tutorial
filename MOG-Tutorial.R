####Mixture of Gaussian  Models: A Tutorial Using simulated VOT data####
#A tutorial using the library Mixtools to model infants' statistical learning of speech sound categories
#The statistical model is a MOG whose parameters are estimated using the EM algorithm
#First, a model is introduced to estimate parameters of VOT distrbutions for voiced/voiceless speech sounds using EM.
#Then, a hypothesis testing approach is introduced to determine the number of components/categories.

####Background Info####
#Model based loosely off of McMurray et al. (2009), Developmental Science, and de Boer & Kuhl (2003), Acoustics Research Letters
#Infants learn speech sound categories based off of distributional features of speech cues.
#Evidence suggests that infant use voice onset time (VOT) to learn voiced and voiceless speech sounds.

####Developmental Caveats####
#McMurray et al. (2009) argue directly against using MOGs with the EM algorithm to model infant statistical learning for two reasons:
#EM algorithm uses a large batch of input, but infants must learn iteratively (i.e., they do not get "batch" data). 
#EM algorithm doesn't learn the number of Gaussians/categories (the number is specified a priori #), only the parameters of the Gaussians are estimated
#In their paper, McMurray et al. (2009) discard the EM alogrithm and use MLE with a competition algorithm.
#Here, I use EM, as that is implemented in the Mixtools library, to learn more about MOGs.

#Mixtools is an R library for MOG
install.packages("mixtools") #Mixtools has built in MOG models with the EM algorithm
library(mixtools)

####Simulate VOT language input####
#Simulated input parameters taken from McMurray et al. (2009), table 1, row 1
#Bimodel distrbution of VOTs reflecting voiced and voiceless speech sounds
#voiced parameters: mean = 0, sd = 5, lambda = 0.5
mu.vd <- 0
sd.vd <- 5
lam.vd <- 0.5

#voiceless: mean = 50, sd = 15, lambda = 0.5
mu.vl <- 50
sd.vl <- 15
lam.vl <- 0.5

#number of samples
n = 1000

#set seed
set.seed(1)

#Sample from normal distribution and create voiced/voiceless factor
VOTs <- c(rnorm(n, mean = mu.vd, sd = sd.vd),rnorm(n, mean = mu.vl, sd = sd.vl))
VOT.type <- factor(rep(c("voiced", "voiceless"), times = c(n,n)))

#Create data frame
VOT.data <- data.frame(VOT.type, VOTs)

head(VOT.data)
dim(VOT.data)

#Plot density by voiced/voiceless
# lattice::histogram(~ VOTs | VOT.type, data = VOT.data, type = "density", breaks = 50)

#Plot density of all VOT data
hist(VOT.data$VOTs, breaks = 75, freq = FALSE, col="grey",border="grey", xlab = "Voice Onset Time (VOT) in Milliseconds", main = "VOT for Voiced and Voiceless")
lines(density(VOT.data$VOTs), lwd = 2)

#### Initialize MOG model with a prioi # of Guassians/cateogires (e.g. K) ####

#We know a priori that the distribution of VOTs is bimodal. Let's try 2 components.
k <- 2 # num of Gaussians/categories

#Run model
# k = number of components/Gaussians
# maxit = max number of iterations for converging the model
# epsilon = run until the log-likelihood changes by less than epsilon. Usually set to 10^-8
mixmdl <- normalmixEM(VOT.data$VOTs, k = k, maxit = 100, epsilon = 0.01)

#Summary of model
summary(mixmdl)

#Fitted parameters. Hey! The fitted parameters match the parameters of the simulated data quite well.
mixmdl$mu
mixmdl$sigma
mixmdl$lambda

#Plot density of VOT data with model fit
#Function that adds the density of a given component of the MOG; scaled by lambda for comparable visualization
plot.normal.components <- function(mixture,component.number,...) {
  curve(mixture$lambda[component.number] *
          dnorm(x,mean=mixture$mu[component.number],
                sd=mixture$sigma[component.number]), add=TRUE, ...)
}

plot(hist(VOT.data$VOTs,breaks=50),col="grey",border="grey",freq=FALSE,
     xlab="Voice Onset Time (VOT) in Milliseconds",main="VOTs for Voiced and Voiceless")
#lines(density(VOT.data$VOTs),lty=2)
#sapply(1:k,plot.normal.components,mixture=mixmdl, lty = 2)
plot.normal.components(mixture=mixmdl, component.number = 1, lty = 2)
plot.normal.components(mixture=mixmdl, component.number = 2, lty = 3)



####Initialize MOG model to have it learn K through bootstrapping and hypothesis testing####
mixmdl.2 <- boot.comp(VOT.data$VOTs,max.comp=15,mix.type="normalmix",
                      maxit=100,epsilon=1e-2)
#Summary
summary(mixmdl.2)
str(mixmdl.2)

#Hypothesis tests
mixmdl.2$p.values
mixmdl.2$obs.log.lik


