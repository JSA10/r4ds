#R4DS
#
#Chapter 3 - Data viz in ggplot2
#
library(tidyverse)

#create scatterplot of mpg to hwy
names(mpg)
#my version from memory
ggplot(mpg, aes(x = displ, y = hwy)) + geom_point()
#r4ds version
ggplot(data = mpg) +
    geom_point(mapping = aes(x = displ, y = hwy))
#extra labels for data and mapping are good for readability and learning but aren't needed
ggplot(mpg) +
    geom_point(aes(x = displ, y = hwy))
##Q - what's better practise putting mapping in core function or geom?

#step by step through ggplot
# ggplot creates a coordinate system, onto which layers can be added
ggplot(data = mpg)
# the first argument is the data and this just creates an empty graph
# geom_point adds a layer of points, which creates a scatterplot
#each geom takes mapping argument, aes(x = , y = ) used to specify variables to map to x and y axis

# A graphing template
ggplot(data = <DATA>) +
    <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))

# Exercises
glimpse(mpg)
table(mpg$drv)
?mpg
ggplot(mpg) +
    geom_point(aes(x = hwy, y = class))
ggplot(mpg) +
    geom_point(aes(x = class, y = drv))

#various options for mapping a third variable - works well for categorical / class variables

ggplot(data = mpg) +
    geom_point(mapping = aes(x = displ, y = hwy, colour = class))

ggplot(data = mpg) +
    geom_point(mapping = aes(x = displ, y = hwy, size = class))
#> Warning: Using size for a discrete variable is not advised

#alpha = transparency
ggplot(data = mpg) +
    geom_point(mapping = aes(x = displ, y = hwy, alpha = class))

ggplot(data = mpg) +
    geom_point(mapping = aes(x = displ, y = hwy, shape = class))
## NOTE: ggplot only uses 6 shapes at a time

# once mapped the visual aesthetic variables, ggplot2 takes care of the rest
# e.g. scale, legend, axis ticks and labels
# Can set all of these manually if prefer:
# - The name of a color as a character string. The size of a point in mm.The shape of a point as a number,
#NOTE: manual aesthetic settings need to be made outside of the aes brakcets, presumably as reserved
# for aesthetics that reflect the data directly
ggplot(mpg) +
    geom_point(aes(x = displ, y = hwy), colour = "turquoise")
?ggplot
?colors
cl <- colors() #657 colour names that r knows about that can be used in ggplot2
cl

# testing out aesthetics with continuous variables
ggplot(mpg) +
    geom_point(aes(x = displ, y = hwy, colour = displ))
ggplot(mpg) +
    geom_point(aes(x = displ, y = hwy, size = hwy))
ggplot(mpg) +
    geom_point(aes(x = displ, y = hwy, shape = cty))
# Colour and Size can handle continuous variables by scaling but shape throws an error as only 6 available

### Facets - another way to add additional variables - particularly useful for categorical data
# facets are subplots that display one subset of the data each
#
ggplot(data = mpg) +
    geom_point(mapping = aes(x = displ, y = hwy)) +
    facet_wrap(~ class, nrow = 2)

#can facet by a combination of two variables
ggplot(data = mpg) +
    geom_point(mapping = aes(x = displ, y = hwy)) +
    facet_grid(drv ~ cyl)
# ~ is called a formula but in R that means a specific data structure
# need discrete variables

#if you prefer to not facet in the rows or columns dimension, use a . instead of a variable name
ggplot(data = mpg) +
    geom_point(mapping = aes(x = displ, y = hwy)) +
    facet_grid(. ~ cyl)
#
#
#