#rm(list = c(Race_form,Rnc))

#applying what we have learned about dplyr and ggplot2
library(tidyverse)

"""
IN EDA You:

Generate questions about your data.

Search for answers by visualising, transforming, and modelling your data.

Use what you learn to refine your questions and/or generate new questions.


Some inspiration

“There are no routine statistical questions, only questionable statistical
routines.”
— Sir David Cox

“Far better an approximate answer to the right question, which is often vague,
than an exact answer to the wrong question, which can always be made precise.”
— John Tukey

Your goal during EDA is to develop an understanding of your data. The easiest
way to do this is to use questions as tools to guide your investigation.

EDA is fundamentally a creative process. And like most creative processes,
the key to asking quality questions is to generate a large quantity of
questions.


Two types of questions will always be useful for making discoveries within your
data. You can loosely word these questions as:

1 What type of variation occurs within my variables?

2 What type of covariation occurs between my variables?

Definitions:

- A variable is a quantity, quality, or property that you can measure.

- A value is the state of a variable when you measure it. The value of a
variable may change from measurement to measurement.

- An observation is a set of measurements made under similar conditions. An
observation will contain several values, each associated with a different
variable. I’ll sometimes refer to an observation as a data point.

- Tabular data is a set of values, each associated with a variable and an
observation. Tabular data is tidy if each value is placed in its own “cell”,
each variable in its own column, and each observation in its own row.

"""

#VARIATION within variables
#Differences depending on categorical or continuous variable

#categorical distribution -  bar chart
ggplot(data = diamonds) +
    geom_bar(mapping = aes(x = cut))
#The height of the bars displays how many observations occurred with each x
#value.

#You can compute these values manually with dplyr::count():
diamonds %>%
    count(cut)


#A variable is continuous if it can take any of an infinite set of ordered
#values.
#Numbers and date-times are two examples of continuous variables.

#To examine the distribution of a continuous variable, use a histogram:
ggplot(data = diamonds) +
    geom_histogram(mapping = aes(x = carat), binwidth = 0.5)

#You can compute this by hand by combining dplyr::count() and ggplot2::cut_width():
diamonds %>%
    count(cut_width(carat, 0.5))

#worth playing around with binwidths as different sizes tell different stories
smaller <- diamonds %>%
    filter(carat < 3)

ggplot(data = smaller, mapping = aes(x = carat)) +
    geom_histogram(binwidth = 0.1)

"""
If you wish to overlay multiple histograms in the same plot, I recommend
using geom_freqpoly() instead of geom_histogram(). geom_freqpoly() performs
the same calculation as geom_histogram(), but instead of displaying the counts
uses lines instead. It’s much easier to understand overlapping lines than bars.
"""

ggplot(data = smaller, mapping = aes(x = carat, colour = cut)) +
    geom_freqpoly(binwidth = 0.1)

"""
The key to asking good follow-up questions will be to rely on your curiosity
(What do you want to learn more about?) as well as your skepticism
(How could this be misleading?).
"""

"""
Useful questions for exploring variation:

Which values are the most common? Why?

Which values are rare? Why? Does that match your expectations?

Can you see any unusual patterns? What might explain them?
"""

#As an example, the histogram below suggests several interesting questions:

ggplot(data = smaller, mapping = aes(x = carat)) +
    geom_histogram(binwidth = 0.01)

#Why are there more diamonds at whole carats and common fractions of carats?

#Why are there more diamonds slightly to the right of each peak than there
#are slightly to the left of each peak?

#Why are there no diamonds bigger than 3 carats?

"""
Clusters of similar values suggest that subgroups exist in your data. To
understand the subgroups, ask:

How are the observations within each cluster similar to each other?

How are the observations in separate clusters different from each other?

How can you explain or describe the clusters?

Why might the appearance of clusters be misleading?
"""
#example
#The histogram below shows the length (in minutes) of 272 eruptions of the
#Old Faithful Geyser in Yellowstone National Park. Eruption times appear to be
#clustered into two groups: there are short eruptions (of around 2 minutes) and
#long eruptions (4-5 minutes), but little in between.

ggplot(data = faithful, mapping = aes(x = eruptions)) +
    geom_histogram(binwidth = 0.25)


## 7.3.3 Unusual values

#Outliers are observations that are unusual; data points that don’t seem to fit
#the pattern. Sometimes outliers are data entry errors; other times outliers
#suggest important new science.

#outliers can be difficult to spot when a lot of data in a historgram

ggplot(diamonds) +
    geom_histogram(mapping = aes(x = y), binwidth = 0.5)
#names(diamonds)
#there is a variable within diamonds dataset named 'y'

#To make it easy to see the unusual values, we need to zoom into the small
#values of the y-axis with coord_cartesian():

ggplot(diamonds) +
    geom_histogram(mapping = aes(x = y), binwidth = 0.5) +
    coord_cartesian(ylim = c(0, 50))

#(coord_cartesian() also has an xlim() argument for when you need to zoom into
#the x-axis. ggplot2 also has xlim() and ylim() functions that work slightly
#differently: they throw away the data outside the limits.)

#there are unusual values at y = 0, ~30 and ~60
#can remove them:
unusual <- diamonds %>%
    filter(y < 3 | y > 20) %>%
    arrange(y)
unusual

#The y variable measures one of the three dimensions of these diamonds, in mm.
#We know that diamonds can’t have a width of 0mm, so these values must be
#incorrect. We might also suspect that measurements of 32mm and 59mm are
#implausible: those diamonds are over an inch long, but don’t cost hundreds
#of thousands of dollars!

#REPEAT ANALYSIS WITH AND WITHOUT OUTLIERS TO DECIDE WHETHER NEED TO REMOVE
#OR EXPLORE FURTHER

#Exercises
#Explore the distribution of each of the x, y, and z variables in diamonds.
#What do you learn? Think about a diamond and how you might decide which
#dimension is the length, width, and depth.

ggplot(data = diamonds) +
    geom_histogram(mapping = aes(x = x))

ggplot(data = diamonds) +
    geom_histogram(mapping = aes(x = x)) +
    coord_cartesian(ylim = c(0, 50))
#the same 7 unusual values found in exploration of y variable also have 0 for
# x and z variables

summary(diamonds$x)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
# 0.000   4.710   5.700   5.731   6.540  10.740

diamonds %>%
    filter(x > 3 & x < 10.71) %>%
    ggplot() +
        geom_histogram(aes(x = x), binwidth = 0.1)

summary(diamonds$y)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
# 0.000   4.720   5.710   5.735   6.540  58.900

diamonds %>%
    filter(y > 0 & y < 20) %>%
    ggplot() +
    geom_histogram(aes(x = y), binwidth = 0.1)

summary(diamonds$z)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
# 0.000   2.910   3.530   3.539   4.040  31.800

ggplot(diamonds) +
    geom_histogram(aes(x = z), binwidth = 0.1) +
    coord_cartesian(ylim = c(0,50))

unusual_z <- diamonds %>%
    filter(z < 1 | z > 10) %>%
    arrange(z)
View(unusual_z)

#z has all the - values of x and y but 13 more, that don't appear at first
#glance to have a pattern that connects them
#There is 1 outlier at 31.8 which otherwise appears normal

diamonds %>%
    filter(z > 2 & z < 6) %>%
    ggplot() +
        geom_histogram(aes(x = z), binwidth = 0.1)

#comparing distributions

x_hist <- diamonds %>%
    filter(x > 3 & x < 10.71) %>%
    ggplot() +
    geom_histogram(aes(x = x), binwidth = 0.1)


y_hist <- diamonds %>%
    filter(y > 0 & y < 20) %>%
    ggplot() +
    geom_histogram(aes(x = y), binwidth = 0.1)


z_hist <- diamonds %>%
    filter(z > 2 & z < 6) %>%
    ggplot() +
    geom_histogram(aes(x = z), binwidth = 0.1)

install.packages("gridExtra")
library(gridExtra)

grid.arrange(x_hist, y_hist, z_hist, ncol=1, nrow =3)


x_box <- diamonds %>%
            filter(x > 3 & x < 10.71) %>%
            ggplot() +
                    geom_boxplot(aes(x=cut, y=x))

y_box <- diamonds %>%
            filter(y > 0 & y < 20) %>%
            ggplot() +
                geom_boxplot(aes(x=cut, y=y))

z_box <- diamonds %>%
            filter(z > 2 & z < 6) %>%
            ggplot() +
                geom_boxplot(aes(x=cut, y=z))

summary(diamonds$price)

ggplot(diamonds) +
    geom_histogram(aes(x=price), binwidth = 500)

ggplot(diamonds) +
    geom_histogram(aes(x=price), binwidth = 1000)

ggplot(diamonds) +
    geom_histogram(aes(x=price), binwidth = 100)

ggplot(diamonds) +
    geom_histogram(aes(x=price), binwidth = 50)

ggplot(diamonds) +
    geom_histogram(aes(x=price), binwidth = 50) +
    coord_cartesian(xlim = c(500,2000))
#no price between 1450 and 1550


#how many diamods are 0.99 carat and how many are 1 carat?
ggplot(diamonds) +
    geom_histogram(aes(x=carat), binwidth = 0.1)
# ~2600 0.99 carat, 6250 = 1 carat
#-- element of rounding up or cutting so it's an even number?

#experiment with coord_cartesian's xlim and ylim

ggplot(diamonds) +
    geom_histogram(aes(x=carat), binwidth = 50) +
    coord_cartesian(xlim = c(0,0.5))
#just see a greyed out plot, as focused in on an area that just contains data
#and no delimting points


#7.4 Using Missing values
"""
#If you’ve encountered unusual values in your dataset, and simply want to move
#on to the rest of your analysis, you have two options.
"""

# 1 Drop the entire row with the strange values:
diamonds2 <- diamonds %>%
    filter(between(y, 3, 20))
"""
I don’t recommend this option because just because one measurement is invalid,
doesn’t mean all the measurements are. Additionally, if you have low quality
data, by time that you’ve applied this approach to every variable you might
find that you don’t have any data left!
"""

"""
Instead, I recommend replacing the unusual values with missing values.
The easiest way to do this is to use mutate() to replace the variable with a
modified copy.
"""
#You can use the ifelse() function to replace unusual values with NA:
diamonds2 <- diamonds %>%
    mutate(y = ifelse(y < 3 | y > 20, NA, y))
#three args: test, value if true, value if false

"""
Like R, ggplot2 subscribes to the philosophy that missing values should never
silently go missing. It’s not obvious where you should plot missing values, so
ggplot2 doesn’t include them in the plot, but it does warn that they’ve been
removed:
"""

ggplot(data = diamonds2, mapping = aes(x = x, y = y)) +
    geom_point()
#> Warning message: Removed 9 rows containing missing values (geom_point).
#To suppress that warning, set na.rm = TRUE

#comapring data with missing values to data without
#create a segment with is.na


nycflights13::flights %>%
    mutate(
        cancelled = is.na(dep_time),
        sched_hour = sched_dep_time %/% 100,
        sched_min = sched_dep_time %% 100,
        sched_dep_time = sched_hour + sched_min / 60
    ) %>%
    ggplot(mapping = aes(sched_dep_time)) +
        geom_freqpoly(mapping = aes(colour = cancelled), binwidth = 1/4)

#scale off between two variables as many more flights than cancelled ones
#- later on we'll look at some techniques for improving

#Exercises

#what happens to missing values in a histogram and a bar chart? Why is there a
# difference?

ggplot(diamonds2) +
    geom_histogram(aes(x=y), binwidth = 0.1)
#Warning message:
#Removed 9 rows containing non-finite values (stat_bin).

ggplot(diamonds2) +
    geom_bar(aes(x=y))
#Warning message:
#Removed 9 rows containing non-finite values (stat_count).

## same response, difference is due to different underlying stats used to create
## each chart - histogram bins data using stat_bin and bar chart creates counts
## for each value using stat_count

# na.rm = TRUE auto removes NAs when used in mean and sum functions



## 7.5 Covariation
"""
If variation describes the behavior within a variable, covariation describes
the behavior between variables. Covariation is the tendency for the values of
two or more variables to vary together in a related way. The best way to spot
covariation is to visualise the relationship between two or more variables. How
you do that should again depend on the type of variables involved.
"""

# C & Q
# Cateogrical variable used to cut up a Quantitative (Continuous) one
#
ggplot(data = diamonds, mapping = aes(x = price)) +
    geom_freqpoly(mapping = aes(colour = cut), binwidth = 500)
#difference in counts for each cut make comparison of distributions difficult

# visualising density does a better job here
ggplot(data = diamonds, mapping = aes(x = price, y = ..density..)) +
    geom_freqpoly(mapping = aes(colour = cut), binwidth = 500)
#same function but rather than y axis defaulting to count, we've explicitly
# asked for y to equal the density - which is the count standardised so that
# the area under each frequency polygon = 1

# A lot going on in the plot above, another alternative = boxplot

#distribution of price by cut
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
    geom_boxplot()

# cut is an ordinal categorical variable so the boxplots are organised accordingly

# class is not ordinal
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
    geom_boxplot()

# one option is to reorganise the order of of categorical variable by the
# quantitative one

# reordering class by median value of hwy
ggplot(data = mpg) +
    geom_boxplot(mapping = aes(x = reorder(class, hwy, FUN = median), y = hwy))


#If you have long variable names, geom_boxplot() will work better if you flip it
#90°. You can do that with coord_flip().
ggplot(data = mpg) +
    geom_boxplot(mapping = aes(x = reorder(class, hwy, FUN = median), y = hwy)) +
    coord_flip()

# 7.5.1.1 Exercises
# return - covers other options for flipping, letter and violin plots as
# alternatives to a boxplot, and jitter for highlighting more data points
#
#
#
#
# 7.5.2 Two categorical variables

#To visualise the covariation between categorical variables, you’ll need to
#count the number of observations for each combination. One way to do that is
#to rely on the built-in geom_count():

ggplot(data = diamonds) +
    geom_count(mapping = aes(x = cut, y = color))

#Covariation will appear as a strong correlation between specific x values and specific y values.

#Another approach is to compute the count with dplyr:
diamonds %>%
    count(color, cut)
## similar to tidytext exercises at LondonR

#Then visualise with geom_tile() and the fill aesthetic:
diamonds %>%
    count(color, cut) %>%
    ggplot(mapping = aes(x = color, y = cut)) +
        geom_tile(mapping = aes(fill = n))

"""
If the categorical variables are unordered, you might want to use the seriation
package to simultaneously reorder the rows and columns in order to more clearly
reveal interesting patterns. For larger plots, you might want to try the
d3heatmap or heatmaply packages, which create interactive plots.
"""

#7.5.2.1 Exercises
# return if want to get more depth


#7.5.3 Two continuous variables

# scatterplots great for looking at covariation (relationships) in 2 Q variables

ggplot(data = diamonds) +
    geom_point(mapping = aes(x = carat, y = price))

#scatteplots do get less useful with large datasets - overplotting

#can adjust transparency with alpha argument
ggplot(data = diamonds) +
    geom_point(mapping = aes(x = carat, y = price), alpha = 1 / 100)
#still tricky with large dataset

### alternative is to bin

# geom_histogram & geom_freqpoly bin 1 variable / dimension
# geom_bin2d() & geom_hex() bin in 2 dimensions

"""
geom_bin2d() and geom_hex() divide the coordinate plane into 2d bins and then
use a fill color to display how many points fall into each bin. geom_bin2d()
creates rectangular bins. geom_hex() creates hexagonal bins. You will need to
install the hexbin package to use geom_hex().
"""

ggplot(data = smaller) +
    geom_bin2d(mapping = aes(x = carat, y = price))

install.packages("hexbin")
library(hexbin)
ggplot(data = smaller) +
    geom_hex(mapping = aes(x = carat, y = price))
#HEXBIN wins - looks much better

"""
Another option is to bin one continuous variable so it acts like a categorical
variable. Then you can use one of the techniques for visualising the combination
of a categorical and a continuous variable that you learned about. For example,
you could bin carat and then for each group, display a boxplot:
"""

ggplot(data = smaller, mapping = aes(x = carat, y = price)) +
    geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)))
#this is a pretty elegant solution, keeps distribution but adds the context
#around density
### looks like a decent option for viewing distribution of each x data range too

"""
cut_width(x, width), as used above, divides x into bins of width width. By
default, boxplots look roughly the same (apart from number of outliers)
regardless of how many observations there are, so it’s difficult to tell that
each boxplot summarises a different number of points. One way to show that is
to make the width of the boxplot proportional to the number of points with
varwidth = TRUE.

Another approach is to display approximately the same number of points in each
bin. That’s the job of cut_number():
"""

ggplot(data = smaller, mapping = aes(x = carat, y = price)) +
    geom_boxplot(mapping = aes(group = cut_number(carat, 20)))


### *** 7.5.3.1Exercises

"""
1. Instead of summarising the conditional distribution with a boxplot, you could
use a frequency polygon. What do you need to consider when using cut_width()
vs cut_number()? How does that impact a visualisation of the 2d distribution
of carat and price?
"""

#ggplot(data = smaller, mapping = aes(x = carat, colour = price)) +
#    geom_freqpoly(mapping = aes(group = cut_width(carat, 1)))

#ggplot(data = smaller, mapping = aes(x = carat, colour = price)) +
#    geom_freqpoly(mapping = aes(group = cut_number(carat, 10)))

ggplot(data = smaller, mapping = aes(x = price)) +
    geom_freqpoly(mapping = aes(group = cut_width(carat, 1)))

ggplot(data = smaller, mapping = aes(x = price, group = cut_width(carat,0.5))) +
    geom_freqpoly()

ggplot(data = smaller, mapping = aes(x = price)) +
    geom_freqpoly(mapping = aes(group = cut_number(carat, 5)))

#not sure cracked this, investigate geom_freqpoly and cut_width / cut_number
#further

?geom_freqpoly

ggplot(diamonds, aes(price, fill = cut)) +
    geom_histogram(binwidth = 500)

ggplot(diamonds, aes(price, colour = cut)) +
    geom_histogram(binwidth = 500)

ggplot(diamonds, aes(price, colour = cut)) +
    geom_freqpoly(binwidth = 500)

?cut_width
?cut_number
Discretise numeric data into categorical
"""
Description

cut_interval makes n groups with equal range, cut_number makes n groups with
(approximately) equal numbers of observations; cut_width makes groups of width
width.
"""

#So think above code is right, want to bin carat, not price. Could do with a
#legend so know which line relates to which carat bin

ggplot(data = smaller, mapping = aes(x = price)) +
    geom_freqpoly(mapping = aes(group = cut_width(carat, 1)), show.legend = TRUE)

ggplot(data = smaller, mapping = aes(x = price, group = cut_width(carat,0.5)), show.legend = TRUE) +
    geom_freqpoly()
#SHOW.LEGEND doesn't seem to work

# ***adding group as colour command works!***
ggplot(data = smaller, mapping = aes(x = price, colour = cut_width(carat, 1))) +
    geom_freqpoly()

ggplot(data = smaller, mapping = aes(x = price, colour = cut_number(carat, 5))) +
    geom_freqpoly()

#My answer:
# to get groups right for both cut_width and cut_number takes experimentation
# or understanding of underlying data
# need to consider picking ranges that don't result in too many bins as these
# will result in a confusing chart with many lines
# depending on data set and need, prefer cut_width as this helps you keep
# regular sized bins. cut_number better for showing the inequality in ranges
# needed to ensur equal observations in each bin


# Q2 visualise the distribution of carat, cut by price
ggplot(data = smaller, mapping = aes(x = price, y = carat)) +
    geom_boxplot(mapping = aes(group = cut_width(price, 1000)))
#started with 100 - way to small bins

#using frequency poly graph
ggplot(data = smaller, mapping = aes(x = carat, colour = cut_width(price, 10000))) +
    geom_freqpoly()
#anything under 1000 takes too long to load - groups too small


# Q3 How does the price distribution of very large diamonds compare to small
# diamonds. Is it as you expect, or does it surprise you?

#Best view using original graph with distribution of price cut by carat
ggplot(data = smaller, mapping = aes(x = carat, y = price)) +
    geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)))

#this shows that distribution of price continues to increase until 2.7 carat
#but then after that the median and lower bound IQR drop significantly as
#approach 3 carat



#Q4 Combine two of the techniques you’ve learned to visualise the combined
#distribution of cut, carat, and price

glimpse(smaller)
#cut = ordinal categorical variable - fair to ideal
table(smaller$cut)
# Fair      Good Very Good   Premium     Ideal
# 1598      4900     12079     13776     21547
summary(smaller$carat)
#carat = continuous variable - 0.2 to 2.8
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
# 0.2000  0.4000  0.7000  0.7961  1.0400  2.8000
summary(smaller$price)
#price = continuous variable 326 to 18,820
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
# 326     949    2400    3925    5315   18820

#continuous vs continuous would probably need to be a scatter plot, with cut
# overlayed with colour or shape - going back to ggplot section

ggplot(data = smaller, mapping = aes(x = carat, y = price)) +
    geom_point(aes(colour = cut))

#same problem with overplotting, but do get extra context with colour
ggplot(data = smaller, mapping = aes(x = carat, y = price)) +
    geom_hex(mapping = aes(colour = cut))
#doesn't quite work - colour of borders = cut, colour of hexbins = count

#try using jitter
ggplot(data = smaller, mapping = aes(x = carat, y = price)) +
    geom_point(aes(colour = cut), position = "jitter")
#perhaps marginally better but not huge amount of difference
?geom_point


#how can use with 'two' of techniques learnt?


#Q5 Two dimensional plots reveal outliers that are not visible in one
#dimensional plots. For example, some points in the plot below have an
#unusual combination of x and y values, which makes the points outliers even
#though their x and y values appear normal when examined separately.
ggplot(data = diamonds) +
    geom_point(mapping = aes(x = x, y = y)) +
    coord_cartesian(xlim = c(4, 11), ylim = c(4, 11))

#Why is a scatterplot a better display than a binned plot for this case?
ggplot(data = diamonds, mapping = aes(x = x, y = y)) +
    geom_boxplot(aes(cut_width(x,1))) +
    coord_cartesian(xlim = c(4, 11), ylim = c(4, 11))
#strength of relationship not as obvious using binned boxplot

ggplot(data = diamonds) +
    geom_hex(mapping = aes(x = x, y = y)) +
    coord_cartesian(xlim = c(4, 11), ylim = c(4, 11))
#same with hexbin - bins give general idea of a positive relationship but
# disguise detail at this level




## 7.6 Patterns and models

"""
Patterns in your data provide clues about relationships. If a systematic
relationship exists between two variables it will appear as a pattern in the
data. If you spot a pattern, ask yourself:

Could this pattern be due to coincidence (i.e. random chance)?

How can you describe the relationship implied by the pattern?

How strong is the relationship implied by the pattern?

What other variables might affect the relationship?

Does the relationship change if you look at individual subgroups of the data?
"""
#example
#A scatterplot of Old Faithful eruption lengths versus the wait time between
#eruptions shows a pattern: longer wait times are associated with longer
#eruptions.

ggplot(data = faithful) +
    geom_point(mapping = aes(x = eruptions, y = waiting))

"""
Patterns provide one of the most useful tools for data scientists because they
reveal covariation. If you think of variation as a phenomenon that creates
uncertainty, covariation is a phenomenon that reduces it. If two variables
covary, you can use the values of one variable to make better predictions about
the values of the second. If the covariation is due to a causal relationship
(a special case), then you can use the value of one variable to control the
value of the second.
"""
#variation == uncertaincty
#covariation == potential certainty and better able to predict or control

"""
Models are a tool for extracting patterns out of data.
"""
"""
#example
#For example, consider the diamonds data. It’s hard to understand the
#relationship between cut and price, because cut and carat, and carat and price
#are tightly related. It’s possible to use a model to remove the very strong
# relationship between price and carat so we can explore the subtleties that
# remain.
"""

#The following code fits a model that predicts price from carat and
# then computes the residuals (the difference between the predicted value and
# the actual value). The residuals give us a view of the price of the diamond,
# once the effect of carat has been removed.

library(modelr)


mod <- lm(log(price) ~ log(carat), data = diamonds)
#my note: from datacamp time series - log discussed as a way of detrending a
# time series

diamonds2 <- diamonds %>%
    add_residuals(mod) %>%
    mutate(resid = exp(resid))

ggplot(data = diamonds2) +
    geom_point(mapping = aes(x = carat, y = resid))

"""
Once you’ve removed the strong relationship between carat and price, you can
see what you expect in the relationship between cut and price: relative to
their size, better quality diamonds are more expensive.
"""

ggplot(data = diamonds2) +
    geom_boxplot(mapping = aes(x = cut, y = resid))

"""
You’ll learn how models, and the modelr package, work in the final part of the
book, model. We’re saving modelling for later because understanding what models
are and how they work is easiest once you have tools of data wrangling and
programming in hand.
"""

### NOTE: From now on ggplot code will be streamlined without explicit naming
### of arg types
"""
The first two arguments to ggplot() are data and mapping, and the first two
arguments to aes() are x and y
"""

#e.g. moving from
ggplot(data = faithful, mapping = aes(x = eruptions)) +
    geom_freqpoly(binwidth = 0.25)

# to
ggplot(faithful, aes(eruptions)) +
    geom_freqpoly(binwidth = 0.25)

"""
Sometimes we’ll turn the end of a pipeline of data transformation into a plot.
Watch for the transition from %>% to +. I wish this transition wasn’t necessary
but unfortunately ggplot2 was created before the pipe was discovered.
"""

diamonds %>%
    count(cut, clarity) %>%
    ggplot(aes(clarity, cut, fill = n)) +
        geom_tile()



