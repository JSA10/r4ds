#r4ds workflow and transformation

#type variable name and can either press tab or enter to auto complete
#if on command line press CMD + UP to get previous commands

#parantheses around assignment causes print to screen to happen alongside assignment
(y <- seq(1, 10, length.out = 5))


#Exercises

library(tidyverse)

names(mpg)

ggplot(data = mpg) +
    geom_point(mapping = aes(x = displ, y = hwy))

filter(mpg, cyl = 8)
filter(diamonds, carat > 3)


### TRANSFORMATION using dplyr

install.packages("nycflights13")
library(nycflights13)
library(tidyverse)
"""
NOTE: dplyr overwrites a couple of base R packages - If want base version need full names:
stats::filter() and stats::lag().
"""

?flights
#On-time data for all flights that departed NYC (i.e. JFK, LGA or EWR) in 2013.
flights
#as data set is tibble format - can print it direct to console and appears as combo of head and dim
#Tibbles are data frames, but slightly tweaked to work better in the tidyverse.

#dplyr basics

"""
Pick observations by their values (filter()).
Reorder the rows (arrange()).
Pick variables by their names (select()).
Create new variables with functions of existing variables (mutate()).
Collapse many values down to a single summary (summarise()).

all five verbs can be used with group_by which changes the scope of each function
from operating on the entire dataset to operating on it group-by-group

All verbs work similarly:

1. The first argument is a data frame.

2. The subsequent arguments describe what to do with the data frame, using the
variable names (without quotes).

3. The result is a new data frame. *****

Together these properties make it easy to chain together multiple simple steps
to achieve a complex result.
"""

filter(flights, month == 1, day == 1)
jan1 <- filter(flights, month == 1, day == 1)
(dec25 <- filter(flights, month == 12, day == 25))

#potential problems with comparison operators

#floating point numbers
sqrt(2) ^ 2 == 2
#> [1] FALSE

#use near instead of ==
near(sqrt(2) ^ 2, 2)
#[1] TRUE

#boolean operators
# & is “and”
# | is “or”
# ! is “not”

filter(flights, month == 11 | month == 12)

"""
The order of operations doesn’t work like English. You can’t write filter(flights, month == 11 | 12),
which you might literally translate into “finds all flights that departed in November or December”.
Instead it finds all months that equal 11 | 12, an expression that evaluates to TRUE.
In a numeric context (like here), TRUE becomes one, so this finds all flights in January,
not November or December. This is quite confusing!

A useful short-hand for this problem is x %in% y. This will select every row where x is one of the
values in y. We could use it to rewrite the code above:
"""

nov_dec <- filter(flights, month %in% c(11, 12))

"""
Sometimes you can simplify complicated subsetting by remembering De Morgan’s law:
!(x & y) is the same as !x | !y,
and !(x | y) is the same as !x & !y.
For example, if you wanted to find flights that weren’t delayed (on arrival or departure)
by more than two hours, you could use either of the following two filters:
"""

filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120, dep_delay <= 120)
#REVISIT

"""
As well as & and |, R also has && and ||. Don’t use them here! You’ll learn when
you should use them in conditional execution.

Whenever you start using complicated, multipart expressions in filter(), consider
making them explicit variables instead. That makes it much easier to check your work.
You’ll learn how to create new variables shortly.
"""

##MISSING VALUES
#...NAs = unknown and are contagious - almost any operation involving an unknown will also be unknown

#The most confusing result is this one:
NA == NA
#> [1] NA

#It’s easiest to understand why this is true with a bit more context:
# Let x be Mary's age. We don't know how old she is.
x <- NA
# Let y be John's age. We don't know how old he is.
y <- NA
# Are John and Mary the same age?
x == y
#> [1] NA
# We don't know!

#use is.na() to check missing values

#filter only includes rows where the condition is TRUE - need to ask for missing
#or FALSE values explicitly if want to preserve them

df <- tibble(x = c(1, NA, 3))
filter(df, x > 1)
#> # A tibble: 1 × 1
#>       x
#>   <dbl>
#> 1     3      #No NA included
filter(df, is.na(x) | x > 1)
#> # A tibble: 2 × 1
#>       x
#>   <dbl>
#> 1    NA
#> 2     3

#Exercises
names(flights)
glimpse(flights)

filter(flights, arr_delay > 120)
# A tibble: 10,034 × 19

filter(flights, dest == "IAH" | dest == "HOU")
# A tibble: 9,313 × 19

table(flights$carrier)
filter(flights, carrier %in% c("AA", "DL", "UA"))
# A tibble: 139,504 × 19

filter(flights, month %in% c(7,8,9))
# A tibble: 86,326 × 19

filter(flights, arr_delay > 120 & dep_delay == 0)
# A tibble: 3 × 19

filter(flights, dep_delay >= 60 & arr_delay <= dep_delay - 30)
# A tibble: 2,074 × 19

filter(flights, dep_time >= 0000 & dep_time <= 0600)
# A tibble: 9,344 × 19

?between
"""
Description
This is a shortcut for x >= left & x <= right, implemented efficiently in C++
for local values, and translated to the appropriate SQL for remote tables.

Usage
between(x, left, right)
"""

#simplifying the above with between

filter(flights, between(month, 7,9))
# A tibble: 86,326 × 19

filter(flights, between(dep_time, 0000, 0600))
# A tibble: 9,344 × 19

#NOTE: between includes the two boundary values, above code = the same results as above


c <- filter(flights, is.na(dep_time))
# A tibble: 8,255 × 19
View(c)
#all these flights have unknown values for all the 'actual' flight time variables
# this might represent cancelled flights

"""
COME BACK TO
Why is NA ^ 0 not missing? Why is NA | TRUE not missing? Why is FALSE & NA not missing?
Can you figure out the general rule? (NA * 0 is a tricky counterexample!)
"""

### ARRANGE
#Works simlarly to filter but arranges rows

#if more than one column name, each additional will be used to break ties in the
#values of preceding columns:

arrange(flights, year, month, day)

#desc() arranges in descending order
arrange(flights, desc(dep_delay))

#missing values always sorted to end
df <- tibble(x = c(5, 2, NA))
arrange(df, x)
#> # A tibble: 3 × 1
#>       x
#>   <dbl>
#> 1     2
#> 2     5
#> 3    NA
arrange(df, desc(x))
#> # A tibble: 3 × 1
#>       x
#>   <dbl>
#> 1     5
#> 2     2
#> 3    NA

#How could you use arrange() to sort all missing values to the start? (Hint: use is.na()).
arrange(df, !is.na(x))
#is.na is a logical condition that evaluates to TRUE or FALSE - 1 or 0, so by reversing it

#Sort flights to find the most delayed flights. Find the flights that left earliest.
arrange(flights, desc(dep_delay), dep_time)
#OR
flights %>%
    arrange(desc(dep_delay)) %>%
    filter(dep_time < 0002)
#got to 2 mins past midnight through process of testing out different dep_times

#Sort flights to find the fastest flights.
names(flights)
arrange(flights, air_time)
View(head(arrange(flights, air_time),10))

#Which flights travelled the longest? Which travelled the shortest?

arrange(flights, desc(distance))
View(head(arrange(flights, desc(distance)),10))
#JFK to NHL

arrange(flights, distance)
View(head(arrange(flights, distance),10))
#EWR to LGA or EWR to PHL


#SELECT
#select helps zoom in on useful subset of data by column, helpful when have very wide data

#select columns by name
select(flights, year, month, day)

#select all columns between year and day (inclusive)
select(flights, year:day)

#select all columns except those from year to day (inclusive)
select(flights, -(year:day))

#helper functions

starts_with("char")
ends_with("char")
contains("char")
matches("(.)\\1") #regex - match any variables with repeated characters.
#More on regex for R in strings section
num_range("x", 1:3) #matches x1, x2 and x3.

?select
"""
Description
select() keeps only the variables you mention; rename() keeps all variables.

Usage
select(.data, ...)
rename(.data, ...)
"""

rename(flights, tail_num = tailnum)

#Can order data frame using select() in conjunction with the everything() helper
#useful for bringing some columns to start of data frame

select(flights, time_hour, air_time, everything())


#Exercises

#Brainstorm as many ways as possible to select dep_time, dep_delay, arr_time,
#and arr_delay from flights.
names(flights)

select(flights, dep_time, dep_delay, arr_time, arr_delay)
select(flights, starts_with("dep"), starts_with("arr"))
select(flights, 4,6,7,9)

?starts_with

#MUTATE
#Add new variables with mutate()
#mutate alwasy adds columns at end of the dataset

#make a smaller dataset so can see what's going on
flights_sml <- select(flights,
                      year:day,
                      ends_with("delay"),
                      distance,
                      air_time
    )

mutate(flights_sml,
       gain = arr_delay - dep_delay,
       speed = distance / air_time * 60
    )

#NOTE: Can refer to columns just created
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours
    )

#If you only want to keep the new variables, use transmute():

transmute(flights,
        gain = arr_delay - dep_delay,
        hours = air_time / 60,
        gain_per_hour = gain / hours
    )


#Many functions can be used to create new variables with mutate - key is that
#they must be vectorised

"""
Arithmetic operators: +, -, *, /, ^
e.g. x / sum(x) calculates the proportion of a total
y - mean(y) computes the difference from the mean

Modular arithmetic: %/% (integer division) and %% (remainder)
where x == y * (x %/% y) + (x %% y).
"""

#Modular arithmetic is a handy tool because it allows you to break integers up into pieces.
#For example, in the flights dataset, you can compute hour and minute from dep_time with
transmute(flights,
          dep_time,
          hour = dep_time %/% 100,
          minute = dep_time %% 100
    )
###*** come back to modular arithmetic

"""
Logs: log(), log2(), log10(). Logarithms are an incredibly useful transformation
for dealing with data that ranges across multiple orders of magnitude. They also
convert multiplicative relationships to additive, a feature we’ll come back to in
modelling.

All else being equal, I recommend using log2() because it’s easy to interpret:
a difference of 1 on the log scale corresponds to doubling on the original scale
and a difference of -1 corresponds to halving.
"""

"""
Offsets: lead() and lag() allow you to refer to leading or lagging values.
This allows you to compute running differences (e.g. x - lag(x)) or find when values
change (x != lag(x)). They are most useful in conjunction with group_by(), which
you’ll learn about shortly.
"""

(x <- 1:10)
#>  [1]  1  2  3  4  5  6  7  8  9 10
lag(x)
#>  [1] NA  1  2  3  4  5  6  7  8  9
lead(x)
#>  [1]  2  3  4  5  6  7  8  9 10 NA

"""
Cumulative and rolling aggregates:

R provides functions for running sums, products, mins and maxes: cumsum(), cumprod(),
cummin(), cummax(); and dplyr provides cummean() for cumulative means.

If you need rolling aggregates (i.e. a sum computed over a rolling window), try the
RcppRoll package.
"""
x
#>  [1]  1  2  3  4  5  6  7  8  9 10
cumsum(x)
#>  [1]  1  3  6 10 15 21 28 36 45 55
cummean(x)
#>  [1] 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5


"""
Logical comparisons
, <, <=, >, >=, !=, which you learned about earlier.

If you’re doing a complex sequence of logical operations it’s often a good idea to
store the interim values in new variables so you can check that each step is working
as expected.
"""

"""
Ranking:
there are a number of ranking functions, but you should start with min_rank().
It does the most usual type of ranking (e.g. 1st, 2nd, 2nd, 4th). The default gives
smallest values the small ranks; use desc(x) to give the largest values the smallest ranks.
"""

y <- c(1, 2, 2, NA, 3, 4)
min_rank(y)
#> [1]  1  2  2 NA  4  5
min_rank(desc(y))
#> [1]  5  3  3 NA  2  1

"""
If min_rank() doesn’t do what you need, look at the variants row_number(),
dense_rank(), percent_rank(), cume_dist(), ntile().
See their help pages for more details.
"""

row_number(y)
#> [1]  1  2  3 NA  4  5
dense_rank(y)
#> [1]  1  2  2 NA  3  4
percent_rank(y)
#> [1] 0.00 0.25 0.25   NA 0.75 1.00
cume_dist(y)
#> [1] 0.2 0.6 0.6  NA 0.8 1.0


#Exercises



#5.6 Grouped summaries with summarise()

#The last key verb is summarise(). It collapses a data frame to a single row:

summarise(flights, delay = mean(dep_delay, na.rm = TRUE))
#> # A tibble: 1 × 1
#>   delay
#>   <dbl>
#> 1  12.6

"""
summarise() is not terribly useful unless we pair it with group_by().
This changes the unit of analysis from the complete dataset to individual groups.
"""

#group data by day
by_day <- group_by(flights, year, month, day)

#same code as above but using grouped by day dataset
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))
#> Source: local data frame [365 x 4]
#> Groups: year, month [?]
#>
#>    year month   day delay
#>   <int> <int> <int> <dbl>
#> 1  2013     1     1 11.55
#> 2  2013     1     2 13.86
#> 3  2013     1     3 10.99
#> # ... with 362 more rows

#group_by and summarise one of most used combinations - grouped summaries.


#Need the PIPE to go further

#Imagine that we want to explore the relationship between the distance and average delay
#for each location. Using what you know about dplyr, you might write code like this:

by_dest <- group_by(flights, dest)

delay <- summarise(by_dest,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE)
)

delay <- filter(delay, count > 20, dest != "HNL")

# It looks like delays increase with distance up to ~750 miles
# and then decrease. Maybe as flights get longer there's more
# ability to make up delays in the air?

ggplot(data = delay, mapping = aes(x = dist, y = delay)) +
    geom_point(aes(size = count), alpha = 1/3) +
    geom_smooth(se = FALSE)
#> `geom_smooth()` using method = 'loess'

"""
There are three steps to prepare this data:

1. Group flights by destination.

2. Summarise to compute distance, average delay, and number of flights.

3. Filter to remove noisy points and Honolulu airport, which is almost twice as
far away as the next closest airport.

This code is a little frustrating to write because we have to give each intermediate
data frame a name, even though we don’t care about it. Naming things is hard, so this
slows down our analysis.

There’s another way to tackle the same problem with the pipe, %>%:
"""

delays <- flights %>%
    group_by(dest) %>%
    summarise(
        count = n(),
        dist = mean(distance, na.rm = TRUE),
        delay = mean(arr_delay, na.rm = TRUE)
    ) %>%
    filter(count > 20, dest != "HNL")

"""
This focuses on the transformations, not what’s being transformed, which makes the
code easier to read. You can read it as a series of imperative statements: group,
then summarise, then filter
"""

"""
Behind the scenes, x %>% f(y) turns into f(x, y), and x %>% f(y) %>% g(z) turns
into g(f(x, y), z) and so on. You can use the pipe to rewrite multiple operations
in a way that you can read left-to-right, top-to-bottom.
"""

#Missing values
#NOTE: na.rm = TRUE needed as aggregation functions obey the usual rule of missing values:
# if there’s any missing value in the input, the output will be a missing value

#In this case, where missing values represent cancelled flights, we could also tackle
#the problem by first removing the cancelled flights. We’ll save this dataset so we can
#reuse in the next few examples.

not_cancelled <- flights %>%
    filter(!is.na(dep_delay), !is.na(arr_delay))

not_cancelled %>%
    group_by(year, month, day) %>%
    summarise(mean = mean(dep_delay))

"""
Whenever you do any aggregation, it’s always a good idea to include either a count (n()),
or a count of non-missing values (sum(!is.na(x))). That way you can check that you’re not
drawing conclusions based on very small amounts of data.
"""

delays <- not_cancelled %>%
    group_by(tailnum) %>%
    summarise(
        delay = mean(arr_delay)
    )

ggplot(data = delays, mapping = aes(x = delay)) +
    geom_freqpoly(binwidth = 10)

#Wow, there are some planes that have an average delay of 5 hours (300 minutes)!
#The story is actually a little more nuanced. We can get more insight if we draw
#a scatterplot of number of flights vs. average delay:

delays <- not_cancelled %>%
    group_by(tailnum) %>%
    summarise(
        delay = mean(arr_delay, na.rm = TRUE),
        n = n()
    )

ggplot(data = delays, mapping = aes(x = n, y = delay)) +
    geom_point(alpha = 1/10)

#Not surprisingly, there is much greater variation in the average delay when there
#are few flights. The shape of this plot is very characteristic: whenever you plot
#a mean (or other summary) vs. group size, you’ll see that the variation decreases
#as the sample size increases.

#When looking at this sort of plot, it’s often useful to filter out the groups with
#the smallest numbers of observations, so you can see more of the pattern and less
#of the extreme variation in the smallest groups. This is what the following code
#does, as well as showing you a handy pattern for integrating ggplot2 into dplyr flows.
#It’s a bit painful that you have to switch from %>% to +, but once you get the
#hang of it, it’s quite convenient.

#integrating ggplot2 into dplyr flows
delays %>%
    filter(n > 40) %>%
    ggplot(mapping = aes(x = n, y = delay)) +
        geom_point(alpha = 1/10)

"""
RStudio tip: a useful keyboard shortcut is Cmd/Ctrl + Shift + P. This resends the
previously sent chunk from the editor to the console. This is very convenient when
you’re (e.g.) exploring the value of n in the example above. You send the whole
block once with Cmd/Ctrl + Enter, then you modify the value of n and press
Cmd/Ctrl + Shift + P to resend the complete block.
"""

#ANOTHER EXAMPLE

"""
There’s another common variation of this type of pattern. Let’s look at how the
average performance of batters in baseball is related to the number of times they’re
at bat. Here I use data from the Lahman package to compute the batting average
(number of hits / number of attempts) of every major league baseball player.

When I plot the skill of the batter (measured by the batting average, ba) against
the number of opportunities to hit the ball (measured by at bat, ab), you see two
patterns:

As above, the variation in our aggregate decreases as we get more data points.

There’s a positive correlation between skill (ba) and opportunities to hit the
ball (ab). This is because teams control who gets to play, and obviously they’ll
pick their best players.
"""

# Convert to a tibble so it prints nicely
install.packages("Lahman")
batting <- as_tibble(Lahman::Batting)

batters <- batting %>%
    group_by(playerID) %>%
    summarise(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
    )

batters %>%
    filter(ab > 100) %>%
    ggplot(mapping = aes(x = ab, y = ba)) +
    geom_point() +
        geom_smooth(se = FALSE)
#> `geom_smooth()` using method = 'gam'

#This also has important implications for ranking. If you naively sort on desc(ba),
#the people with the best batting averages are clearly lucky, not skilled:

batters %>%
    arrange(desc(ba))
#> # A tibble: 18,659 × 3
#>    playerID    ba    ab
#>       <chr> <dbl> <int>
#> 1 abramge01     1     1
#> 2 banisje01     1     1
#> 3 bartocl01     1     1
#> 4  bassdo01     1     1
#> 5 birasst01     1     2
#> 6 bruneju01     1     1
#> # ... with 1.865e+04 more rows

#visualise version without filter on ab - clearly the items with low volume are skewing results
#this problem is similar to ERs for posts with very low volumes of reach - remove from averages

batters %>%
    #filter(ab > 100) %>%
    ggplot(mapping = aes(x = ab, y = ba)) +
    geom_point() +
    geom_smooth(se = FALSE)
#> `geom_smooth()` using method = 'gam'


#5.6.4 Useful summary functions

#summary stats
n()
n_distinct()
sum()   #sum(!is.na(x)) to count number of non missing values
#central tendency
mean()
median()
#measures of spread
sd()
IQR()
mad()  #median absolute deviation - along with IQR more robust to outliers than sd
#measures of rank
min()
quantile(x, 0.25)   #find a value of x that is greater than 25% of the values, and less than the remaining 75%.
max()
#Measures of position:
first()
nth(x, 2)
last()


"""
It’s sometimes useful to combine aggregation with logical subsetting. We haven’t
talked about this sort of subsetting yet, but you’ll learn more about it in subsetting.
"""

not_cancelled %>%
    group_by(year, month, day) %>%
    summarise(
        avg_delay1 = mean(arr_delay),
        avg_delay2 = mean(arr_delay[arr_delay > 0]) # the average positive delay
    )

#NOTE: group_by year, month, day = effectively a pivot table


# Why is distance to some destinations more variable than to others?
not_cancelled %>%
    group_by(dest) %>%
    summarise(distance_sd = sd(distance)) %>%
    arrange(desc(distance_sd))


# When do the first and last flights leave each day?
not_cancelled %>%
    group_by(year, month, day) %>%
    summarise(
        first = min(dep_time),
        last = max(dep_time)
    )

"""
Measures of position: first(x), nth(x, 2), last(x). These work similarly to x[1], x[2],
and x[length(x)] but let you set a default value if that position does not exist
(i.e. you’re trying to get the 3rd element from a group that only has two elements).
For example, we can find the first and last departure for each day:
"""

not_cancelled %>%
    group_by(year, month, day) %>%
    summarise(
        first_dep = first(dep_time),
        last_dep = last(dep_time)
    )


#These functions are complementary to filtering on ranks. Filtering gives you all
#variables, with each observation in a separate row:

not_cancelled %>%
    group_by(year, month, day) %>%
    mutate(r = min_rank(desc(dep_time))) %>%
    filter(r %in% range(r))

"""
Counts: You’ve seen n(), which takes no arguments, and returns the size of the current
group. To count the number of non-missing values, use sum(!is.na(x)). To count the
number of distinct (unique) values, use n_distinct(x)
"""

# Which destinations have the most carriers?
not_cancelled %>%
    group_by(dest) %>%
    summarise(carriers = n_distinct(carrier)) %>%
    arrange(desc(carriers))

#Counts are so useful that dplyr provides a simple helper if all you want is a count:

not_cancelled %>%
    count(dest)

#You can optionally provide a weight variable. For example, you could use this to
#“count” (sum) the total number of miles a plane flew:

not_cancelled %>%
    count(tailnum, wt = distance)

"""
Counts and proportions of logical values: sum(x > 10), mean(y == 0). When used with
numeric functions, TRUE is converted to 1 and FALSE to 0. This makes sum() and mean()
very useful: sum(x) gives the number of TRUEs in x, and mean(x) gives the proportion.
"""

# How many flights left before 5am? (these usually indicate delayed
# flights from the previous day)
not_cancelled %>%
    group_by(year, month, day) %>%
    summarise(n_early = sum(dep_time < 500))

#> Source: local data frame [365 x 4]
#> Groups: year, month [?]
#>
#>    year month   day n_early
#>   <int> <int> <int>   <int>
#> 1  2013     1     1       0
#> 2  2013     1     2       3
#> 3  2013     1     3       4
#> 4  2013     1     4       3
#> 5  2013     1     5       3
#> 6  2013     1     6       2
#> # ... with 359 more rows

# What proportion of flights are delayed by more than an hour?
not_cancelled %>%
    group_by(year, month, day) %>%
    summarise(hour_perc = mean(arr_delay > 60))

#the argument within the mean call is almost like a conditional statement
#out of all flights on that day, what % had arrival delay > 1hr

#5.6.5 Grouping by multiple variables
"""
When you group by multiple variables, each summary peels off one level of the
grouping. That makes it easy to progressively roll up a dataset:
"""

daily <- group_by(flights, year, month, day)
(per_day   <- summarise(daily, flights = n()))
(per_month <- summarise(per_day, flights = sum(flights)))
(per_year <- summarise(per_month, flights = sum(flights)))

"""
Be careful when progressively rolling up summaries: it’s OK for sums and counts,
but you need to think about weighting means and variances, and it’s not
possible to do it exactly for rank-based statistics like the median. In other
words, the sum of groupwise sums is the overall sum, but the median of
groupwise medians is not the overall median.
"""


#5.6.6 Ungrouping

"""
If you need to remove grouping, and return to operations on ungrouped data,
use ungroup().
"""

daily %>%
    ungroup() %>%             # no longer grouped by date
    summarise(flights = n())  # all flights


#5.6.7 Exercises
#return to do them



#5.7 Grouped mutates (and filters)
"""
Grouping is most useful in conjunction with summarise(), but you can also do
convenient operations with mutate() and filter():
"""

#Find the worst members of each group:

flights_sml %>%
    group_by(year, month, day) %>%
    filter(rank(desc(arr_delay)) < 10)

#Find all groups bigger than a threshold:

(popular_dests <- flights %>%
    group_by(dest) %>%
    filter(n() > 365))

#Standardise to compute per group metrics:

popular_dests %>%
    filter(arr_delay > 0) %>%
    mutate(prop_delay = arr_delay / sum(arr_delay)) %>%
    select(year:day, dest, arr_delay, prop_delay)

"""
A grouped filter is a grouped mutate followed by an ungrouped filter.
I generally avoid them except for quick and dirty manipulations: otherwise
it’s hard to check that you’ve done the manipulation correctly.

Functions that work most naturally in grouped mutates and filters are known
as window functions (vs. the summary functions used for summaries). You can
learn more about useful window functions in the corresponding vignette:
vignette('window-functions).
"""


