#r4ds workflow
#
##r4ds workflow and transformation

#type variable name and can either press tab or enter to auto complete
#if on command line press CMD + UP to get previous commands

#parantheses around assignment causes print to screen to happen alongside assignment
(y <- seq(1, 10, length.out = 5))



### workflow 8 - projects
#see summary at end for key takeaways

"""
One day you will need to quit R, go do something else and return to your
analysis the next day. One day you will be working on multiple analyses
simultaneously that all use R and you want to keep them separate. One day you
will need to bring data from the outside world into R and send numerical results
and figures from R back out into the world. To handle these real life
situations, you need to make two decisions:

1. What about your analysis is “real”, i.e. what will you save as your lasting
record of what happened?

2. Where does your analysis “live”?


As a beginning R user, it’s OK to consider your environment (i.e. the objects
listed in the environment pane) “real”. However, in the long run, you’ll be much
better off if you consider your R scripts as “real”.

There is a great pair of keyboard shortcuts that will work together to make
sure you’ve captured the important parts of your code in the editor:

Press Cmd/Ctrl + Shift + F10 to restart RStudio.
Press Cmd/Ctrl + Shift + S to rerun the current script.

I use this pattern hundreds of times a week.
"""


"""
8.4 RStudio projects

R experts keep all the files associated with a project together — input data,
R scripts, analytical results, figures. This is such a wise and common practice
that RStudio has built-in support for this via projects.
"""

## created new r4ds project in DataScience folder

getwd()
#[1] "/Users/jeromeahye/Documents/DataScience/r4ds"

"""
Now enter the following commands in the script editor, and save the file,
calling it “diamonds.R”. Next, run the complete script which will save a PDF
and CSV file into your project directory. Don’t worry about the details, you’ll
learn them later in the book.
"""

#below saved in diamonds.r file with r4ds project folder
library(tidyverse)

ggplot(diamonds, aes(carat, price)) +
    geom_hex()
ggsave("diamonds.pdf")

write_csv(diamonds, "diamonds.csv")

#this next part is important

"""
Quit RStudio. Inspect the folder associated with your project — notice the
.Rproj file. Double-click that file to re-open the project. Notice you get back
to where you left off: it’s the same working directory and command history, and
all the files you were working on are still open. Because you followed my
instructions above, you will, however, have a completely fresh environment,
guaranteeing that you’re starting with a clean slate.

In your favorite OS-specific way, search your computer for diamonds.pdf and
you will find the PDF (no surprise) but also the script that created it
(diamonds.r). This is huge win! One day you will want to remake a figure or
just understand where it came from.

*** If you rigorously save figures to files with R code and never with the mouse
or the clipboard, you will be able to reproduce old work with ease! ***
"""

"""
8.5 Summary

In summary, RStudio projects give you a solid workflow that will serve you well in the future:

Create an RStudio project for each data analyis project.

Keep data files there; we’ll talk about loading them into R in data import.

Keep scripts there; edit them, run them in bits or as a whole.

Save your outputs (plots and cleaned data) there.

Only ever use relative paths, not absolute paths.

Everything you need is in one place, and cleanly separated from all the other
projects that you are working on.
"""

