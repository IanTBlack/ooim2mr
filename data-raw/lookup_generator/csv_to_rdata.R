#install.packages("rio")
require(rio)

#setwd('')
lookup = import("ooi_science.csv")
export(lookup,"ooi_science.RData")
