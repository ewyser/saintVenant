# initialisation & global definition(s)
using Plots, LaTeXStrings, Base.Threads, ProgressMeter, CSV, DataFrames
# include dependencies
include(joinpath("./"     , "misc.jl"))
include(joinpath("./"     , "hillshade.jl"))
include(joinpath("./"     , "plots.jl"))
include(joinpath("./"     , "geometry.jl"))
	include(joinpath("./bc"   , "getBCs.jl"))
	include(joinpath("./flux" , "fluxes.jl"))
	include(joinpath("./flux" , "HLL.jl"))
	include(joinpath("./flux" , "HLLC.jl"))
	include(joinpath("./flux" , "Rus.jl"))
	include(joinpath("./flux" , "wellBal.jl"))
	include(joinpath("./solve", "advSolve.jl"))
	include(joinpath("./solve", "get.jl"))
	include(joinpath("./solve", "souSolve.jl"))
	include(joinpath("./solve", "svSolver.jl"))
	include(joinpath("./upd"  , "update.jl"))