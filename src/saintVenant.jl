module saintVenant
export geoflow,runoff,coast,basin # host code
export geoflow_D,runoff_D # device code
# include dependencies & function call(s)
include(joinpath("./fun"  , "_superORCH.jl"  )) # standard dependencies
    try
        include(joinpath("./fun_D", "_superORCH_D.jl")) # additional dependencies for Device & GPU computing
        t = ["method(s) available:\n\t",
             "(✓) geoflow()\n\t └─ (✓) geoflow_D()\n\t",
             "(✓) runoff() \n\t └─ (✓) runoff_D() \n\t", 
             "(✓) coast()  \n\t",
             "(✓) basin()"]   
        @info t[1]*t[2]*t[3]*t[4]*t[5]
    catch err
        @error err
        @warn "CUDA dependencies not found: [.]_D generic methods might not be working on device\nCUDA package should be manually added"
        t = ["method(s) available:\n\t",
             "(✓) geoflow()\n\t └─ (✗) geoflow_D()\n\t",
             "(✓) runoff() \n\t └─ (✗) runoff_D() \n\t", 
             "(✓) coast()  \n\t",
             "(✓) basin()"]    
        @info t[1]*t[2]*t[3]*t[4]*t[5]
    end
# initialize & generate outputs and data folders
    global path_plot = "./viz/out/"
    if isdir(path_plot)==false
        mkdir(path_plot)    
    end
    global path_save = "./viz/dat/"
    if isdir(path_save)==false
        mkdir(path_save)    
    end
    @info path_plot*" and "*path_save*" relative paths generated..."    
# include geoflow routine in saintVenant module
    @doc raw"""
        geoflow(lx::Float64,ly::Float64,nx::Int64,T::Float64,tC::Float64,rheoType::String,solvType::String,isViz::Bool): solves a non-linear hyperbolic 2D Saint-Venant problem considering a Coulomb-type rheology within a finite volume framework on a Cartesian grid
        # args:
        - lx       : dimension along the x-direciton in [m].
        - ly       : dimension along the y-direciton in [m].
        - nx       : number of grid nodes along the x-direction  in [-].
        - T        : total simulation time in [s].
        - tC       : time interval for saving/plotting
        - rheoType : select the rheology, i.e., "coulomb", "newtonian" or "plastic"
        - solveType: select the numerical flux, i.e., "Rusanov", "HLL" or "HLLC"
        - isViz    : plot or save, true or false
        To run geoflow() on a GPU, add *_D, i.e., geoflow_D(lx::Float64,ly::Float64,nx::Int64,T::Float64,tC::Float64,rheoType::String,solvType::String,isViz::Bool)
    """
    geoflow()
    include(joinpath("../scripts", "geoflow.jl"))
# include runoff routine in saintVenant module
    @doc raw"""
        runoff(path::String, xm::Tuple,ym::Tuple,T::Float64,tC::Float64,isViz::Bool): solves a non-linear hyperbolic 2D Saint-Venant problem considering a Newtonian-type rheology within a finite volume framework on a Cartesian grid
        # args:
        - path     : path (absolute or relative) to a DSM/DTM/DEM in .asc format
        - xm       : min and max coordinates along x-direction
        - ym       : min and max coordinates along y-direction
        - T        : total simulation time in [s].
        - tC       : time interval for saving/plotting
        - isViz    : plot or save, i.e., true or false
        On Windows OS, use "/" instead of "\" for the path 
    """
    runoff()
    include(joinpath("../scripts", "runoff.jl"))
# include coast routine in saintVenant module
    include(joinpath("../scripts", "coast.jl"))
# include basin routine in saintVenant module
    include(joinpath("../scripts", "basin.jl"))   
# showcase
    @info "first run ever ?\n\t - copy-paste the following: \n\t\tgeoflow(10.0,10.0,200,10.0,1.0/25.0,\"coulomb\",\"HLLC\",true)\n\t - wait for the simulation to end"
end

#=
----------------------------------------------------------------------
                **FOR DEVELOPMENT**

When changing stuffs within the module, in REPL, enter the following:
    julia> include("./src/saintVenant.jl")
    WARNING: replacing module saintVenant.
    Main.saintVenant
    julia> saintVenant.geoflow(20.0,10.0,200)

----------------------------------------------------------------------
geoflow(10.0,10.0,200,10.0,1.0/25.0,"coulomb","HLLC",true)
=#