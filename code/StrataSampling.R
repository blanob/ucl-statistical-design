# Prelim:
digits <- 2

# Load population data (with name pop):
load(file="pop.data.Rdata")

# Pop size:
N  <- nrow(pop)
# Strata sizes:
Ns <- table(pop$size.cat)
K  <- length(Ns)

# Look at population and the strata variances:
boxplot(pop$wheat.yield~pop$size.cat, col="green", 
        xlab = "Strata", ylab= "Wheat Yield", cex.lab=1.5)

# Sampling parameters:
n <- 100 
f <- n/N

##################
# SRS:

# Use R function sample() to sample; see help(sample):
draw  <- sample(1:N, size = n, replace = FALSE)
y     <- pop$wheat.yield[draw]
# Use definitions and theory in Section 4.3.1:
y.bar     <- mean(y)
S2        <- 1/(n-1)*sum( (y-y.bar)^2 )
var.y.bar <- (1-f)*S2/n

# Output:
cat("\nSRS:\n")
cat("Estimated pop mean = ", round(y.bar,digits))
cat("\nwith estimated variance = ", round(var.y.bar,digits))
cat("\nEstimated pop variance = ", round(S2,digits))

##################
# Stratified sampling (PA):

# Strata sample sizes:
ns <- round(Ns*f)
# Ad hoc correction if needed:
if( sum(ns)<n ){ns[1] <- ns[1]+1}
if( sum(ns)>n ){ns[1] <- ns[1]-1}

# Sampling using definitions and theory in Section 2.6.2:
y.bar <- rep(NA,K)
S2    <- rep(NA,K)
for(k in 1:K){
  stratum  <- pop[pop$size.cat == k, ]
  draw     <- sample(1:Ns[k], size = ns[k], replace = FALSE)
  y        <- stratum$wheat.yield[draw]
  y.bar[k] <- mean(y)
  S2[k]    <- 1/(ns[k]-1)*sum( (y-y.bar[k])^2 )
}
y.bar.ST   <- 1/N*sum(Ns*y.bar)
var.y.bar  <- 1/(N^2)*sum(Ns*S2)*(1-f)/f 

# Output:
cat("\n\nStratified sampling (PA):\n")
cat("Estimated pop mean = ", round(y.bar.ST,digits))
cat("\nwith estimated variance = ", round(var.y.bar,digits))
cat("\nEstimated pop variances = ", round(S2,digits))
