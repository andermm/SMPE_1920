
library(DoE.base)
set.seed(0)
wscad <- fac.design(factor.names = list(
  kernels = c("bt.", "ep.", "cg.", "mg.", "lu.", "sp."),
  inputs = c("C.x", "D.x")),
  replications=30, 
  randomize=TRUE)
  print(wscad)

export.design(wscad,
              filename = "projeto-experimental",
              type = "csv",
              replace = TRUE
)