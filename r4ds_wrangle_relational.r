#r4ds wrangle - Relational Data


#13 Relational data

#13.1 Introduction
"""
It’s rare that a data analysis involves only a single table of data. Typically
you have many tables of data, and you must combine them to answer the questions
that you’re interested in. Collectively, multiple tables of data are called
relational data because it is the relations, not just the individual datasets,
that are important.

Relations are always defined between a pair of tables. All other relations are
built up from this simple idea: the relations of three or more tables are always
a property of the relations between each pair. Sometimes both elements of a
pair can be the same table! This is needed if, for example, you have a table of
people, and each person has a reference to their parents.

To work with relational data you need verbs that work with pairs of tables.
There are three families of verbs designed to work with relational data:

1. Mutating joins, which add new variables to one data frame from matching
observations in another.

2. Filtering joins, which filter observations from one data frame based on
whether or not they match an observation in the other table.

3. Set operations, which treat observations as if they were set elements.

The most common place to find relational data is in a relational database
management system (or RDBMS), a term that encompasses almost all modern
databases. If you’ve used a database before, you’ve almost certainly used SQL.
If so, you should find the concepts in this chapter familiar, although their
expression in dplyr is a little different. Generally, dplyr is a little easier
to use than SQL because dplyr is specialised to do data analysis: it makes
common data analysis operations easier, at the expense of making it more
difficult to do other things that aren’t commonly needed for data analysis.
"""

#use dplyr to explore relational data from nyc13

library(nycflights13)
#contains 4 datasets - is related to flights data used in transformation section

#1. airlines lets you look up the full carrier name from its abbreviated code:
#2. airports gives information about each airport, identified by the faa airport
# code
#3. planes gives information about each plane, identified by its tailnum:
#4. weather gives the weather at each NYC airport for each hour

# visualising relationships in a diagram is useful (can sometimes be daunting)
"""
The key to understanding diagrams like this is to remember each relation always
concerns a pair of tables. You don’t need to understand the whole thing; you
just need to understand the chain of relations between the tables that you are
interested in.

For nycflights13:

flights connects to planes via a single variable, tailnum.

flights connects to airlines through the carrier variable.

flights connects to airports in two ways: via the origin and dest variables.

flights connects to weather via origin (the location), and year, month, day and
hour (the time).
"""

# 13.2.1 exercises - return if want to understand relational tables conceptually
# and for more context on nycflights dataset

glimpse(airports)
airports %>%
    count(faa) %>%
    filter(faa == 'EWR')

?count
glimpse(weather)



# 13.3 KEYS

# Variables used to connect tables = keys
# Key = variable or set of variables used to uniquely identify an observation
# Key can be single variable e.g. tailnum for plane
# OR multiple variables e.g. year, month, day, hour, and origin used to
# identify a weather observation

"""
There are two types of keys:

A primary key uniquely identifies an observation in its own table. For example,
planes$tailnum is a primary key because it uniquely identifies each plane in
the planes table.

A foreign key uniquely identifies an observation in another table. For example,
the flights$tailnum is a foreign key because it appears in the flights table
where it matches each flight to a unique plane.

A variable can be both a primary key and a foreign key. For example, origin is
part of the weather primary key, and is also a foreign key for the airport
table.
"""

#Once you’ve identified the primary keys in your tables, it’s good practice to
#verify that they do indeed uniquely identify each observation. One way to do
#that is to count() the primary keys and look for entries where n is greater
#than one:

planes %>%
    count(tailnum) %>%
    filter(n > 1)
#> # A tibble: 0 × 2
#> # ... with 2 variables: tailnum <chr>, n <int>

weather %>%
    count(year, month, day, hour, origin) %>%
    filter(n > 1)
#> Source: local data frame [0 x 6]
#> Groups: year, month, day, hour [0]
#>
#> # ... with 6 variables: year <dbl>, month <dbl>, day <int>, hour <int>,
#> #   origin <chr>, n <int>

"""
Sometimes a table doesn’t have an explicit primary key: each row is an
observation, but no combination of variables reliably identifies it. For
example, what’s the primary key in the flights table? You might think it would
be the date plus the flight or tail number, but neither of those are unique:
"""

flights %>%
    count(year, month, day, flight) %>%
    filter(n > 1)
#> Source: local data frame [29,768 x 5]
#> Groups: year, month, day [365]
#>
#>    year month   day flight     n
#>   <int> <int> <int>  <int> <int>
#> 1  2013     1     1      1     2
#> 2  2013     1     1      3     2
#> 3  2013     1     1      4     2
#> 4  2013     1     1     11     3
#> 5  2013     1     1     15     2
#> 6  2013     1     1     21     2
#> # ... with 2.976e+04 more rows

flights %>%
    count(year, month, day, tailnum) %>%
    filter(n > 1)
#> Source: local data frame [64,928 x 5]
#> Groups: year, month, day [365]
#>
#>    year month   day tailnum     n
#>   <int> <int> <int>   <chr> <int>
#> 1  2013     1     1  N0EGMQ     2
#> 2  2013     1     1  N11189     2
#> 3  2013     1     1  N11536     2
#> 4  2013     1     1  N11544     3
#> 5  2013     1     1  N11551     2
#> 6  2013     1     1  N12540     2
#> # ... with 6.492e+04 more rows

"""
If a table lacks a primary key, it’s sometimes useful to add one with
mutate() and row_number(). That makes it easier to match observations if
you’ve done some filtering and want to check back in with the original data.
This is called a *surrogate key*.
"""

"""
A primary key and the corresponding foreign key in another table form a
relation. Relations are typically one-to-many. For example, each flight has
one plane, but each plane has many flights. In other data, you’ll occasionally
see a 1-to-1 relationship. You can think of this as a special case of
1-to-many. You can model many-to-many relations with a many-to-1 relation
plus a 1-to-many relation. For example, in this data there’s a many-to-many
relationship between airlines and airports: each airline flies to many airports;
each airport hosts many airlines.
"""

#13.3.1 Exercises

#Add a surrogate key to flights.
glimpse(flights)

flights2 <- flights %>%
    mutate(flight_ref = row_number())

glimpse(flights2)

#Identify the keys in the following datasets
"""
Lahman::Batting,
babynames::babynames
nasaweather::atmos
fueleconomy::vehicles
ggplot2::diamonds
(You might need to install some packages and read some documentation.)
"""
library(Lahman)
glimpse(Batting)
#playerID looks like primary key - can check:
Batting %>%
    count(playerID) %>%
    filter(n > 1)
#13665 rows with more than one entry unfortunately
str(Batting)
?Batting
Batting %>%
    count(stint)

#Draw a diagram illustrating the connections between the Batting, Master,
#and Salaries tables in the Lahman package. Draw another diagram that shows
#the relationship between Master, Managers, AwardsManagers.

#How would you characterise the relationship between the Batting, Pitching,
#and Fielding tables?


# 13.4 mutating joins
"""
A mutating join allows you to combine variables from two tables. It first
matches observations by their keys, then copies across variables from one
table to the other.
"""
# Can shorten data set with lots of columns in order to see what's going
# when new columns added - or use View from dplyr

flights %>%
    left_join(airlines, by = "carrier") %>%
    View()

#The result of joining airlines to flights2 is an additional variable: name.

