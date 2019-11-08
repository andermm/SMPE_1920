  library(DoE.base)
  set.seed(0)
  smpe <- fac.design(factor.names = list(
    apps = c("bt.D.x", "ep.D.x", "cg.D.x", "mg.D.x", "lu.D.x", "sp.D.x", "is.D.x", "ft.D.x"),
    interface = c("eth", "ib", "ipoib")),
    replications=30,
    randomize=TRUE)
    print(smpe)
  
  write.table(smpe, file = "experimental_project.csv",
                sep=";"
  )