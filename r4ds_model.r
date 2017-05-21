#R4DS - IV MODEL
#
#23.1 Intro
#modelr package which wraps around base R’s modelling functions to make them work naturally in a pipe.
#
library(tidyverse)
library(modelr)
options(na.action = na.warn)

#simulated dataset sim1 - simple with two variables

g <- ggplot(sim1, aes(x, y))
g + geom_point()

#see a strong pattern -> use a model to make it explicit
#need to supply basic form of the model -> in this case it looks like a linear relationship

#Practise with a few randomly generated models
models <- tibble(
    a1 = runif(250, -20, 40),
    a2 = runif(250, -5, 5)
)

#use geom_abline to add straight lines -> needs intercept and slope as inputs
g + geom_abline(aes(intercept = a1, slope = a2), data = models, alpha = 1/4) +
    geom_point()
#Woah
#this fits 250 random models onto the plot - most are terrible
#
#simple start point
#need to calculate distance between the models 'predictions' and the 'actual' data points to assess

#To compute first turn model family into an R function.
#This takes the model parameters (a[1] = intercept and a[2] = slope)
#and the data as inputs, and gives values predicted by the model as output:
model1 <- function(a, data) {
    a[1] + data$x * a[2]
}

model1(c(7, 1.5), sim1)
#7 = intercept and 1.5 = slope

#root mean squared deviation - a popular way to compute overall distance btw predicted and actual
#values - gets it down to 1 number

"""
*** Investigate difference between OLS (Ordinary Least Squares)
From https://stats.stackexchange.com/questions/146092/mean-squared-error-versus-least-squared-error-which-one-to-compare-datasets
'To sum up, keep in mind that LSE is a method that builds a model and MSE is a metric that evaluate
your model's performances.'
"""

#function to calculate RMSE - we take the difference between actual and predicted,
#square them, take the average and then take the squre root
measure_distance <- function(mod, data) {
    diff <- data$y - model1(mod, data)
    sqrt(mean(diff ^ 2))
}
#RMSE = (sq)Root, Mean, Square of the Difference(Error)

measure_distance(c(7, 1.5), sim1)
#> [1] 2.67 = RMSE

#Now we can use purrr to compute the distance for all the models defined above.
#We need a helper function because our distance function expects the model as a
#numeric vector of length 2.

sim1_dist <- function(a1, a2) {
    measure_distance(c(a1, a2), sim1)
}

models <- models %>%
    mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))
models

#Next overlay 10 best models on data
g + geom_point(size = 2, colour = "grey30") +
    geom_abline(
        aes(intercept = a1, slope = a2, colour = -dist),
        data = filter(models, rank(dist) <= 10)
    )
#-dist arg to colour function in reverse order, with low = good
#rank used as conditional operator to select the models with rank based on dist
#less than or equal to 10

#We can also think about these models as observations, and visualising with a scatterplot
#of a1 vs a2, again coloured by -dist

ggplot(models, aes(a1, a2)) +
    geom_point(data = filter(models, rank(dist) <= 10), size = 4, colour = "red") +
    geom_point(aes(colour = -dist))
#top 10 models coloured red

#Instead of trying lots of random models, we could be more systematic and generate
#an evenly spaced grid of points (this is called a grid search)

grid <- expand.grid(
    a1 = seq(-5, 20, length = 25),
    a2 = seq(1, 3, length = 25)
    ) %>%
    mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))

grid %>%
    ggplot(aes(a1, a2)) +
    geom_point(data = filter(grid, rank(dist) <= 10), size = 4, colour = "red") +
    geom_point(aes(colour = -dist))


When you overlay the best 10 models back on the original data, they all look pretty good:

g +
    geom_point(size = 2, colour = "grey30") +
    geom_abline(
        aes(intercept = a1, slope = a2, colour = -dist),
        data = filter(grid, rank(dist) <= 10)
    )

"""
You could imagine iteratively making the grid finer and finer until you narrowed
in on the best model. But there’s a better way to tackle that problem: a numerical
minimisation tool called Newton-Raphson search. The intuition of Newton-Raphson is
pretty simple: you pick a starting point and look around for the steepest slope.
You then ski down that slope a little way, and then repeat again and again, until
you can’t go any lower. In R, we can do that with optim():
"""

best <- optim(c(0, 0), measure_distance, data = sim1)
best$par
#> [1] 4.22 2.05

g +
    geom_point(size = 2, colour = "grey30") +
    geom_abline(intercept = best$par[1], slope = best$par[2])

"""
Don’t worry too much about the details of how optim() works. It’s the intuition
that’s important here. If you have a function that defines the distance between a
model and a dataset, an algorithm that can minimise that distance by modifying the
parameters of the model, you can find the best model. The neat thing about this
approach is that it will work for any family of models that you can write an equation for.
"""

"""
There’s one more approach that we can use for this model, because it’s is a special
case of a broader family: linear models. A linear model has the general form
y = a_1 + a_2 * x_1 + a_3 * x_2 + ... + a_n * x_(n - 1). So this simple model is
equivalent to a general linear model where n is 2 and x_1 is x. R has a tool
specifically designed for fitting linear models called lm(). lm() has a special
way to specify the model family: formulas. Formulas look like y ~ x, which lm()
will translate to a function like y = a_1 + a_2 * x. We can fit the model and
look at the output:
"""

sim1_mod <- lm(y ~ x, data = sim1)
coef(sim1_mod)
#> (Intercept)           x
#>        4.22        2.05

#same result as previous steps
"""
Behind the scenes lm() doesn’t use optim() but instead takes advantage of the
mathematical structure of linear models. Using some connections between geometry,
calculus, and linear algebra, lm() actually finds the closest model in a single step,
using a sophisticated algorithm. This approach is both faster, and guarantees that
there is a global minimum.
"""



