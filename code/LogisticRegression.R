################################################################################
#
#           UCL Statistical Design and Data Ethics (Spring 2025)
#
#           Chap. 3.5: Logistic Regression and Classification
#
################################################################################

y <- c(rep(1,25),rep(0,75))
glm(y ~ 1, family = binomial())
summary(glm(y ~ 1, family = binomial()))

# Prelim:
set.seed(123)
# Data:
y <- c(rep(0,10),rep(1,10))
x <- rnorm(n=length(y), mean=y, sd=1/2)
# Fit the model:
model <- glm(y ~ x, family = binomial())
print(summary(model))

predict(model)

pred  <- predict(model, type = "response")
label <- ifelse(pred>.5,1,0)
plot(x, label)