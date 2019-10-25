  library(DoE.base)
  set.seed(0)
  wscad <- fac.design(factor.names = list(
    kernels = c("bt.", "ep.", "cg.", "mg.", "lu.", "sp.", "is.", "ft."),
    inputs = c("C.x", "D.x"),
    btl = c("^tcp", "tcp,self")),
    replications=30,
    randomize=TRUE)
    print(wscad)
  
  write.table(wscad, file = "experimental_project.csv",
                sep=";",
  )