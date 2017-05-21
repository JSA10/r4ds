#r4ds programming


# Pipes -------------------------------------------------------------------





# Functions ---------------------------------------------------------------


# readability tips:
# - generally function names should be verbs, arguments are nouns
# - remember Functions are for HUMANS + computers
# - use consistent naming style and argument order: e.g.
# -- e.g. snake_case
# -- consistent prefix better than sufix for family of function -> auto complete
# ---- e.g. str_...
#
# shortcut to create code headers (Cmd/Ctrl + Shift + R)
#


# Conditions --------------------------------------------------------------

# if allows you to conditionally execute code
if (condition) {
    #execute when true
} else {
    #execute when false
}

# need backticks for help
?`if`  #includes other control flow statements

"""
*Standard return rule: a function returns the last value that it computed.
Here that is either one of the two branches of the if statement.
"""

# 19.4.1 Conditions

"""
The condition must evaluate to either TRUE or FALSE. If it’s a vector, you’ll
get a warning message; if it’s an NA, you’ll get an error. Watch out for these
messages in your own code:

You can use || (or) and && (and) to combine multiple logical expressions.
These operators are “short-circuiting”: as soon as || sees the first TRUE it
returns TRUE without computing anything else. As soon as && sees the first
FALSE it returns FALSE. You should never use | or & in an if statement: these
are vectorised operations that apply to multiple values (that’s why you use
them in filter()). If you do have a logical vector, you can use any() or all()
to collapse it to a single value.

Be careful when testing for equality. == is vectorised, which means that it’s
easy to get more than one output. Either check the length is already 1,
collapse with all() or any(), or use the non-vectorised identical().
identical() is very strict: it always returns either a single TRUE or a
single FALSE, and doesn’t coerce types. This means that you need to be careful
when comparing integers and doubles:
"""
identical(0L, 0)
#> [1] FALSE

#You also need to be wary of floating point numbers:

x <- sqrt(2) ^ 2
x
#> [1] 2
x == 2
#> [1] FALSE
x - 2
#> [1] 4.44e-16

#Instead use dplyr::near() for comparisons, as described in comparisons.

#And remember, x == NA doesn’t do anything useful!



?switch



# Arguments ---------------------------------------------------------------

#19.5.1 Choosing names

"""
The names of the arguments are also important. R doesn’t care, but the readers
of your code (including future-you!) will. Generally you should prefer longer,
more descriptive names, but there are a handful of very common, very short
names. It’s worth memorising these:

x, y, z: vectors.
w: a vector of weights.
df: a data frame.
i, j: numeric indices (typically rows and columns).
n: length, or number of rows.
p: number of columns.

Otherwise, consider matching names of arguments in existing R functions.
For example, use na.rm to determine if missing values should be removed.
"""

