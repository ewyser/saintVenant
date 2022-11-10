@views function geoflow(lx::Float64,ly::Float64,nx::Int64,T::Float64,tC::Float64,rheoType::String,solvType::String,isViz::Bool)
    Dsim   = param(solvType,false,rheoType,false)
    #Dsim   = param("HLLC",false,"newtonian",false)
    # physical constant
    g      = 9.81
    # number of points
    ny     = Int64((ly/lx)*nx)
    Qx     = zeros(Float64,nx,ny)
    Qy     = zeros(Float64,nx,ny)
    #h,z,xc,yc,Δx,Δy = staron_etal_2004(lx,ly,nx,ny)
    h,z,xc,yc,Δx,Δy = zhang_etal_2022(lx,ly,nx,ny)
    #h,z,xc,yc,Δx,Δy = incline(lx,ly,nx,ny)
    #h,z,xc,yc,Δx,Δy = bowl_floor(lx,ly,nx,ny)
    # action
    CFL    = 0.5
    if isViz == true
        svSolver(xc,yc,h,Qx,Qy,z,g,CFL,T,tC,lx,ly,Δx,Δy,nx,ny,Dsim)
    elseif isViz == false
        svSolverPerf(xc,yc,h,Qx,Qy,z,g,CFL,T,tC,lx,ly,Δx,Δy,nx,ny,Dsim)
    end
end
@views function geoflow_D(lx::Float64,ly::Float64,nx::Int64,T::Float64,tC::Float64,rheoType::String,solvType::String,isViz::Bool)
    Dsim   = param(solvType,false,rheoType,false)
    #Dsim   = param("HLLC",false,"newtonian",false)
    # physical constant
    g      = 9.81
    # number of points
    ny     = Int64((ly/lx)*nx)
    Qx     = zeros(Float64,nx,ny)
    Qy     = zeros(Float64,nx,ny)
    h,z,xc,yc,Δx,Δy = incline(lx,ly,nx,ny)
    #h,z,xc,yc,Δx,Δy = bowl_floor(lx,ly,nx,ny)
    # action
    CFL    = 0.5
    if isViz == true
        svSolver_D(xc,yc,h,Qx,Qy,z,g,CFL,T,tC,lx,ly,Δx,Δy,nx,ny,Dsim)
    elseif isViz == false
        svSolverPerf_D(xc,yc,h,Qx,Qy,z,g,CFL,T,tC,lx,ly,Δx,Δy,nx,ny,Dsim)
    end
end