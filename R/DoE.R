  library(DoE.base)
  set.seed(0)
  wscad <- fac.design(factor.names = list(
    kernels = c("bt.D.x", "ep.D.x", "cg.D.x", "mg.D.x", "lu.D.x", "sp.D.x", "is.D.x", "ft.D.x"),
    btl = c("tcp --mca btl_tcp_if_include ib0", "tcp --mca btl_tcp_if_include eno2", "openib")),
    replications=30,
    randomize=TRUE)
    print(wscad)
  
  write.table(wscad, file = "experimental_project.csv",
                sep=";",
  )