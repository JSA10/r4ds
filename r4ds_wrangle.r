#r4ds chapter 9 wrangle
#
#9.1 Tibbles
#tibbles are an updated version of data frames, with a few tweaks that iron
# out old bugs from base R versions that are circa 20 years old and work better
# in tidyverse

library(tidyverse)
#coerce data frames into tibbles
as_tibble(iris)

#You can create a new tibble from individual vectors with tibble()
#tibble() will automatically recycle inputs of length 1, and allows you to
#refer to variables that you just created, as shown below.
tibble(x = 1:5, y = 1, z = x ^ 2 + y)
#> # A tibble: 5 × 3
#>       x     y     z
#>   <int> <dbl> <dbl>
#> 1     1     1     2
#> 2     2     1     5
#> 3     3     1    10
#> 4     4     1    17
#> 5     5     1    26

"""
If you’re already familiar with data.frame(), note that tibble() does much
less: it never changes the type of the inputs (e.g. it never converts strings
to factors!), it never changes the names of variables, and it never creates
row names.

It’s possible for a tibble to have column names that are not valid R variable
names, aka non-syntactic names. For example, they might not start with a letter,
or they might contain unusual characters like a space. To refer to these
variables, you need to surround them with backticks, `:
"""

tb <- tibble(
    `:)` = "smile",
    ` ` = "space",
    `2000` = "number"
)
tb
#> # A tibble: 1 × 3
#>    `:)`   ` ` `2000`
#>   <chr> <chr>  <chr>
#> 1 smile space number

"""
You’ll also need the backticks when working with these variables in other
packages, like ggplot2, dplyr, and tidyr.
"""

#TRIBBLES
"""
Another way to create a tibble is with tribble(), short for transposed tibble.
tribble() is customised for data entry in code: column headings are defined by
formulas (i.e. they start with ~), and entries are separated by commas. This
makes it possible to lay out small amounts of data in easy to read form.
"""
tribble(
    ~x, ~y, ~z,
    #--|--|----
    "a", 2, 3.6,
    "b", 1, 8.5
)

#> # A tibble: 2 × 3
#>       x     y     z
#>   <chr> <dbl> <dbl>
#> 1     a     2   3.6
#> 2     b     1   8.5

#I often add a comment (the line starting with #), to make it really clear
#where the header is.


#tibbles vs. data frames
# printing and subsetting are main differences

#printing
#printing tibbles by name shows only first 10 rows and columns that fit on page
# = easier to work with big data
# also each column displays data type - feature borrowed by str

#when need to display more data
# 1. use print and control rows and cols with n and width
nycflights13::flights %>%
    print(n = 10, width = Inf)

# 2. use options to set default print behaviour
options(tibble.print_max = n, tibble.print_min = m)
#if more than m rows, print only n rows.

#Use options(dplyr.print_min = Inf) to always show all rows.
#Use options(tibble.width = Inf) to always print all columns, regardless of the
#width of the screen.

#You can see a complete list of options by looking at the package help with
#package?tibble.

# 3. A final option is to use RStudio’s built-in data viewer to get a scrollable
#view of the complete dataset. This is also often useful at the end of a long
#chain of manipulations.

nycflights13::flights %>%
    View()
# remember can use commands like head etc. to control amount displayed using
# view()


#subsetting
#use same tools as dataframes - $ and [[]] but tibbles are stricter
# - never do partial matching and will generate a warning if the column doesn't
# exist

# remember:
# [[]] matches name or position,
# $ only matches by name but less typing

df <- tibble(
    x = runif(5),
    y = rnorm(5)
)
df$x
#> [1] 0.434 0.395 0.548 0.762 0.254
df[["x"]]
#> [1] 0.434 0.395 0.548 0.762 0.254
# Extract by position
df[[1]]

# To use these in a pipe, you’ll need to use the special placeholder .:
df %>% .$x
#> [1] 0.434 0.395 0.548 0.762 0.254
df %>% .[["x"]]
#> [1] 0.434 0.395 0.548 0.762 0.254


## 10.4 Interacting with older code
"""
Some older functions don’t work with tibbles. If you encounter one of these
functions, use as.data.frame() to turn a tibble back to a data.frame:
"""
class(as.data.frame(tb))
#> [1] "data.frame"
"""
The main reason that some older functions don’t work with tibble is the
[ function. We don’t use [ much in this book because dplyr::filter() and
dplyr::select() allow you to solve the same problems with clearer code
(but you will learn a little about it in vector subsetting). With base R
data frames, [ sometimes returns a data frame, and sometimes returns a vector.
With tibbles, [ always returns another tibble.
"""

#10.5 Exercises
# come back to if want to practise
# also if want to go deeper check out: vignette("tibble")


## 11 Data import

# using readr package

"""
11.2 Getting started

Most of readr’s functions are concerned with turning flat files into data
frames:

read_csv() reads comma delimited files, read_csv2() reads semicolon separated
files (common in countries where , is used as the decimal place), read_tsv()
reads tab delimited files, and read_delim() reads in files with any delimiter.

read_fwf() reads fixed width files. You can specify fields either by their
widths with fwf_widths() or their position with fwf_positions(). read_table()
reads a common variation of fixed width files where columns are separated by
white space.

read_log() reads Apache style log files. (But also check out webreadr which
is built on top of read_log() and provides many more helpful tools.)

These functions all have similar syntax: once you’ve mastered one, you can use
the others with ease. For the rest of this chapter we’ll focus on read_csv().
Not only are csv files one of the most common forms of data storage, but once
you understand read_csv(), you can easily apply your knowledge to all the other
functions in readr.
"""

#The first argument to read_csv() is the most important: it’s the path to the
#file to read.

heights <- read_csv("data/heights.csv")

"""
When you run read_csv() it prints out a column specification that gives the
name and type of each column. That’s an important part of readr, which we’ll
come back to in parsing a file.
"""
#you can also supply an inline csv file. This is useful for experimenting with
#readr and for creating reproducible examples to share with others:

read_csv("a,b,c
1,2,3
4,5,6")
#> # A tibble: 2 × 3
#>       a     b     c
#>   <int> <int> <int>
#> 1     1     2     3
#> 2     4     5     6

#two cases where might not want first line to be columns:

# 1. Some metadata at top of the file
# skip = n    to skip n lines
# comment = "#"     to drop any lines that start with #
#

read_csv("The first line of metadata
  The second line of metadata
  x,y,z
  1,2,3", skip = 2)

read_csv("# A comment I want to skip
  x,y,z
  1,2,3", comment = "#")

# 2. Data might not have column names
# use col_names = FALSE
read_csv("1,2,3\n4,5,6", col_names = FALSE)
# NOTE: "\n" is a convenient shortcut for adding a new line. More in strings

# or can pass col_names a character vector with new names
read_csv("1,2,3\n4,5,6", col_names = c("x", "y", "z"))


# can identify the values in file to be imported that represent missing values
read_csv("a,b,c\n1,2,.", na = ".")
#> # A tibble: 1 × 3
#>       a     b     c
#>   <int> <int> <chr>
#> 1     1     2  <NA>

"""
This is all you need to know to read ~75% of CSV files that you’ll encounter in
practice. You can also easily adapt what you’ve learned to read tab separated
files with read_tsv() and fixed width files with read_fwf().

To read in more challenging files, you’ll need to learn more about how readr
parses each column, turning them into R vectors.
"""

"""
11.2.1 Compared to base R

If you’ve used R before, you might wonder why we’re not using read.csv(). There
are a few good reasons to favour readr functions over the base equivalents:

They are typically much faster (~10x) than their base equivalents. Long running
jobs have a progress bar, so you can see what’s happening. If you’re looking
for raw speed, try data.table::fread(). It doesn’t fit quite so well into the
tidyverse, but it can be quite a bit faster.

They produce tibbles, they don’t convert character vectors to factors, use row
names, or munge the column names. These are common sources of frustration with
the base R functions.

They are more reproducible. Base R functions inherit some behaviour from your
operating system and environment variables, so import code that works on your
computer might not work on someone else’s.
"""

## section on parsing vectors is useful reading for understanding how readr
## works

"""
Using parsers is mostly a matter of understanding what’s available and how they
deal with different types of input. There are eight particularly important
parsers:

parse_logical() and parse_integer() parse logicals and integers respectively.
There’s basically nothing that can go wrong with these parsers so I won’t
describe them here further.

parse_double() is a strict numeric parser, and parse_number() is a flexible
numeric parser. These are more complicated than you might expect because
different parts of the world write numbers in different ways.

parse_character() seems so simple that it shouldn’t be necessary. But one
complication makes it quite important: character encodings.

parse_factor() create factors, the data structure that R uses to represent
categorical variables with fixed and known values.

parse_datetime(), parse_date(), and parse_time() allow you to parse various
date & time specifications. These are the most complicated because there are
so many different ways of writing dates.
"""

#for now just need basics - use the import section as a reference as you go

read_csv()
# In order to allocate character types automatically readr uses a strategy of
# analyzing first 1000 rows and then 'guessing' the col type using certain rules
# worth knowing as can lead to problems in a couple special examples.

"""
The heuristic tries each of the following types, stopping when it finds a match:

logical: contains only “F”, “T”, “FALSE”, or “TRUE”.
integer: contains only numeric characters (and -).
double: contains only valid doubles (including numbers like 4.5e-5).
number: contains valid doubles with the grouping mark inside.
time: matches the default time_format.
date: matches the default date_format.
date-time: any ISO8601 date.
If none of these rules apply, then the column will stay as a vector of strings.
"""

write_csv(object, "filename.csv")
#NOTE: writing to a csv is good for compatibility of sharing (UTF-8 and
#date/time in ISO8601 format), but doesn't preserve r formatting and metadata)
#use rds format for caching / saving interim data that will work on again
"""
write_rds() and read_rds() are uniform wrappers around the base functions
readRDS() and saveRDS(). These store data in R’s custom binary format called
RDS
"""
write_rds(challenge, "challenge.rds")
read_rds("challenge.rds")


#11.6 Other types of data
"""
To get other types of data into R, we recommend starting with the tidyverse
packages listed below. They’re certainly not perfect, but they are a good
place to start. For rectangular data:

haven reads SPSS, Stata, and SAS files.

readxl reads excel files (both .xls and .xlsx).

DBI, along with a database specific backend (e.g. RMySQL, RSQLite, RPostgreSQL
etc) allows you to run SQL queries against a database and return a data frame.

For hierarchical data: use jsonlite (by Jeroen Ooms) for json, and xml2 for
XML. Jenny Bryan has some excellent worked examples at
https://jennybc.github.io/purrr-tutorial/examples.html.

For other file types, try the R data import/export manual and the rio package.
"""




### 12. TIDY DATA

#Recap

#There are three interrelated rules which make a dataset tidy:

#1. Each variable must have its own column.
#2. Each observation must have its own row.
#3. Each value must have its own cell.

"""
These three rules are interrelated because it’s impossible to only satisfy
two of the three. That interrelationship leads to an even simpler set of
practical instructions:

*****
BROADLY THERE ARE TWO JOBS TO DO TO MAKE DATA TIDY:
Put each dataset in a tibble.
Put each variable in a column.
*****

"""


"""
Why ensure that your data is tidy? There are two main advantages:

1. There’s a general advantage to picking one consistent way of storing data. If
you have a consistent data structure, it’s easier to learn the tools that work
with it because they have an underlying uniformity.

2. There’s a specific advantage to placing variables in columns because it allows
R’s vectorised nature to shine. As you learned in mutate and summary functions,
most built-in R functions work with vectors of values. That makes transforming
tidy data feel particularly natural.

dplyr, ggplot2, and all the other packages in the tidyverse are designed to
work with tidy data.
"""

#examples

# Compute rate per 10,000
table1 %>%
    mutate(rate = cases / population * 10000)

# Compute cases per year
table1 %>%
    count(year, wt = cases)

# Visualise changes over time
library(ggplot2)
ggplot(table1, aes(year, cases)) +
    geom_line(aes(group = country), colour = "grey50") +
    geom_point(aes(colour = country))


"""
The principles of tidy data seem so obvious that you might wonder if you’ll
ever encounter a dataset that isn’t tidy. Unfortunately, however, most data
that you will encounter will be untidy. There are two main reasons:

1. Most people aren’t familiar with the principles of tidy data, and it’s hard to
derive them yourself unless you spend a lot of time working with data.

2. Data is often organised to facilitate some use other than analysis. For example,
data is often organised to make entry as easy as possible.

This means for most real analyses, you’ll need to do some tidying. The first
step is always to figure out what the variables and observations are. Sometimes
this is easy; other times you’ll need to consult with the people who originally
generated the data. The second step is to resolve one of two common problems:

One variable might be spread across multiple columns.

One observation might be scattered across multiple rows.

Typically a dataset will only suffer from one of these problems; it’ll only
suffer from both if you’re really unlucky! To fix these problems, you’ll need
the two most important functions in tidyr: gather() and spread().
"""

# GATHER
# gather() used when you have columns that aren't distinct variables, likely to
#  be categories within a variable that could be combined. So rather than
#  having 1999, 2000, 2001 as columns they can all be 'gathered' into 1 column
#  called Years
gather('colnames', key = new_var_name, value = new_value_name)
#e.g.
table4a
#> # A tibble: 3 × 3
#>       country `1999` `2000`
#> *       <chr>  <int>  <int>
#> 1 Afghanistan    745   2666
#> 2      Brazil  37737  80488
#> 3       China 212258 213766
table4a %>%
    gather(`1999`, `2000`, key = "year", value = "cases")
#this gathers the columns 1999 and 2000 into two new columns labelled year and
#cases
"""
Hadley version
To tidy a dataset like this, we need to gather those columns into a new pair of
variables. To describe that operation we need three parameters:

1. The set of columns that represent values, not variables. In this example, those
are the columns 1999 and 2000.

2.The name of the variable whose values form the column names. I call that the
key, and here it is year.

3. The name of the variable whose values are spread over the cells. I call that
value, and here it’s the number of cases.
"""

# SPREAD
# spread() solves the opposite problem, use when an observation is spread
# across multiple rows

#e.g
table2
#> # A tibble: 12 × 4
#>       country  year       type     count
#>         <chr> <int>      <chr>     <int>
#> 1 Afghanistan  1999      cases       745
#> 2 Afghanistan  1999 population  19987071
#> 3 Afghanistan  2000      cases      2666
#> 4 Afghanistan  2000 population  20595360
#> 5      Brazil  1999      cases     37737
#> 6      Brazil  1999 population 172006362
#> # ... with 6 more rows

"""
Need two parameters:

1. The column that contains variable names, the key column. Here, it’s type.

2. The column that contains values forms multiple variables, the value column.
Here it’s count.
"""
spread(table2, key = type, value = count)
#> # A tibble: 6 × 4
#>       country  year  cases population
#> *       <chr> <int>  <int>      <int>
#> 1 Afghanistan  1999    745   19987071
#> 2 Afghanistan  2000   2666   20595360
#> 3      Brazil  1999  37737  172006362
#> 4      Brazil  2000  80488  174504898
#> 5       China  1999 212258 1272915272
#> 6       China  2000 213766 1280428583


# Separating & Uniting
"""
separate() pulls apart one column into multiple columns, by splitting wherever
a separator character appears. Take table3:
"""

table3
#> # A tibble: 6 × 3
#>       country  year              rate
#> *       <chr> <int>             <chr>
#> 1 Afghanistan  1999      745/19987071
#> 2 Afghanistan  2000     2666/20595360
#> 3      Brazil  1999   37737/172006362
#> 4      Brazil  2000   80488/174504898
#> 5       China  1999 212258/1272915272
#> 6       China  2000 213766/1280428583

# problem looks very similar to an Excel 'text to columns' job

table3 %>%
    separate(rate, into = c("cases", "population"))
# defaults to splitting on any non alpha numeric character it finds

# can specify the separator using sep argument
table3 %>%
    separate(rate, into = c("cases", "population"), sep = "/")
# sep = a regular expression (more in strings)

# BE CAREFUL WITH COL FORMAT
# Separate leaves the column type as it was originally by default. In this case
# the column was characters, so both cases and population have adopted

# in order to parse to a more appropriate type, use convert argument:
table3 %>%
    separate(rate, into = c("cases", "population"), convert = TRUE)

"""
You can also pass a vector of integers to sep. separate() will interpret the
integers as positions to split at. Positive values start at 1 on the far-left
of the strings; negative value start at -1 on the far-right of the strings.
When using integers to separate strings, the length of sep should be one less
than the number of names in into.
"""
#e.g. separate the last two digits of each year. This make this data less tidy,
#but is useful in other cases, as you’ll see in a little bit.
table3 %>%
    separate(year, into = c("century", "year"), sep = 2)
#> # A tibble: 6 × 4
#>       country century  year              rate
#> *       <chr>   <chr> <chr>             <chr>
#> 1 Afghanistan      19    99      745/19987071
#> 2 Afghanistan      20    00     2666/20595360
#> 3      Brazil      19    99   37737/172006362
#> 4      Brazil      20    00   80488/174504898
#> 5       China      19    99 212258/1272915272
#> 6       China      20    00 213766/1280428583

## Unite
"""
unite() is the inverse of separate(): it combines multiple columns into a
single column. You’ll need it much less frequently than separate(), but it’s
still a useful tool to have in your back pocket.
"""
# Uniting `table5` makes it tidy
#We can use unite() to rejoin the century and year columns that we created in
#the last example. That data is saved as tidyr::table5. unite() takes a data
#frame, the name of the new variable to create, and a set of columns to
#combine, again specified in dplyr::select() style:

table5 %>%
    unite(new, century, year)
#> # A tibble: 6 × 3
#>       country   new              rate
#> *       <chr> <chr>             <chr>
#> 1 Afghanistan 19_99      745/19987071
#> 2 Afghanistan 20_00     2666/20595360
#> 3      Brazil 19_99   37737/172006362
#> 4      Brazil 20_00   80488/174504898
#> 5       China 19_99 212258/1272915272
#> 6       China 20_00 213766/1280428583

#in this case also need sep argument as default is to place an underscore btw
#columns
# we don't want any separator so use ""
table5 %>%
    unite(new, century, year, sep = "")


#12.5 Missing values
"""
Changing the representation of a dataset brings up an important subtlety of
missing values. Surprisingly, a value can be missing in one of two possible
ways:

1. Explicitly, i.e. flagged with NA.
2. Implicitly, i.e. simply not present in the data.
"""
#Let’s illustrate this idea with a very simple data set:
stocks <- tibble(
        year   = c(2015, 2015, 2015, 2015, 2016, 2016, 2016),
        qtr    = c(   1,    2,    3,    4,    2,    3,    4),
        return = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
    )
"""
There are two missing values in this dataset:

The return for the fourth quarter of 2015 is explicitly missing, because the
cell where its value should be instead contains NA.

The return for the first quarter of 2016 is implicitly missing, because it
simply does not appear in the dataset.

One way to think about the difference is with this Zen-like koan: An explicit
missing value is the presence of an absence; an implicit missing value is the
absence of a presence.
"""

# making implicit missing values explicit
#
# 1. display in a table format
stocks %>%
    spread(year, return)
#> # A tibble: 4 × 3
#>     qtr `2015` `2016`
#> * <dbl>  <dbl>  <dbl>
#> 1     1   1.88     NA
#> 2     2   0.59   0.92
#> 3     3   0.35   0.17
#> 4     4     NA   2.66


#Because these explicit missing values may not be important in other
#representations of the data, you can set na.rm = TRUE in gather() to turn
#explicit missing values implicit:
stocks %>%
    spread(year, return) %>%
    gather(year, return, `2015`:`2016`, na.rm = TRUE)
#> # A tibble: 6 × 3
#>     qtr  year return
#> * <dbl> <chr>  <dbl>
#> 1     1  2015   1.88
#> 2     2  2015   0.59
#> 3     3  2015   0.35
#> 4     2  2016   0.92
#> 5     3  2016   0.17
#> 6     4  2016   2.66

"""
Another important tool for making missing values explicit in tidy data is
complete():
"""
stocks %>%
    complete(year, qtr)
#> # A tibble: 8 × 3
#>    year   qtr return
#>   <dbl> <dbl>  <dbl>
#> 1  2015     1   1.88
#> 2  2015     2   0.59
#> 3  2015     3   0.35
#> 4  2015     4     NA
#> 5  2016     1     NA
#> 6  2016     2   0.92
#> # ... with 2 more rows

#complete() takes a set of columns, and finds all unique combinations. It then
#ensures the original dataset contains all those values, filling in explicit
#NAs where necessary.

"""
There’s one other important tool that you should know for working with missing
values. Sometimes when a data source has primarily been used for data entry,
missing values indicate that the previous value should be carried forward:
"""
treatment <- tribble(
        ~ person,           ~ treatment, ~response,
        "Derrick Whitmore", 1,           7,
        NA,                 2,           10,
        NA,                 3,           9,
        "Katherine Burke",  1,           4
    )
"""
You can fill in these missing values with fill(). It takes a set of columns
where you want missing values to be replaced by the most recent non-missing
value (sometimes called last observation carried forward).
"""
treatment %>%
    fill(person)
#> # A tibble: 4 × 3
#>             person treatment response
#>              <chr>     <dbl>    <dbl>
#> 1 Derrick Whitmore         1        7
#> 2 Derrick Whitmore         2       10
#> 3 Derrick Whitmore         3        9
#> 4  Katherine Burke         1        4




## CASE STUDY - pulling it all together
# WHO data case study a useful worked through example of tidying a dataset
# final code pipeline
who %>%
    gather(code, value, new_sp_m014:newrel_f65, na.rm = TRUE) %>%
    mutate(code = stringr::str_replace(code, "newrel", "new_rel")) %>%
    separate(code, c("new", "var", "sexage")) %>%
    select(-new, -iso2, -iso3) %>%
    separate(sexage, c("sex", "age"), sep = 1)

"""
12.7 Non-tidy data

Before we continue on to other topics, it’s worth talking briefly about non-tidy
data. Earlier in the chapter, I used the pejorative term “messy” to refer to
non-tidy data. That’s an oversimplification: there are lots of useful and
well-founded data structures that are not tidy data. There are two main reasons
to use other data structures:

Alternative representations may have substantial performance or space
advantages.

Specialised fields have evolved their own conventions for storing data that
may be quite different to the conventions of tidy data.

Either of these reasons means you’ll need something other than a tibble (or
data frame). If your data does fit naturally into a rectangular structure
composed of observations and variables, I think tidy data should be your
default choice. But there are good reasons to use other structures; tidy data
is not the only way.

If you’d like to learn more about non-tidy data, I’d highly recommend this
thoughtful blog post by Jeff Leek:
http://simplystatistics.org/2016/02/17/non-tidy-data/
"""

