@views function runoff(path::String,xm::Tuple,ym::Tuple,T::Float64,tC::Float64,isViz::Bool)
    Dsim   = param("HLLC",
                    false,
                    "newtonian",
                    true
                )
    # physical constant
    g     = 9.81
    # number of points
    d = Array(CSV.read(path,DataFrame,header=false; delim="\t", limit=6))
    Δx= Float64(d[5])
    Δy= Δx
    z = Array(CSV.read(path,DataFrame,header=false; delim=" ", skipto=8)[:,2:end])
    z = (z[1:end,180:end])'
    nx,ny = size(z)
    xc= 0.0:Δx:(nx-1)*Δx
    yc= 0.0:Δy:(ny-1)*Δy

    xId = findall(x->x>xm[1] && x<xm[2],xc)
    yId = findall(x->x>ym[1] && x<ym[2],yc)

    z0    = copy(z[xId,yId])

    nx,ny = size(z0)
    xc0   = 0.0:Δx:(nx-1)*Δx
    yc0   = 0.0:Δy:(ny-1)*Δy

    h     = 1.0e-6.*ones(Float64,nx,ny)
    Qx    = zeros(Float64,nx,ny)
    Qy    = zeros(Float64,nx,ny)
    # action
    CFL   = 0.5
    if isViz == true
        svSolver(xc0,yc0,h,Qx,Qy,z0,g,CFL,T,tC,maximum(xc),maximum(yc),Δx,Δy,nx,ny,Dsim)
    elseif isViz == false
        svSolverPerf(xc0,yc0,h,Qx,Qy,z0,g,CFL,T,tC,maximum(xc),maximum(yc),Δx,Δy,nx,ny,Dsim)
    end
end
@views function runoff_D(path::String,xm::Tuple,ym::Tuple,T::Float64,tC::Float64,isViz::Bool)
    Dsim   = param("HLLC",
                    false,
                    "newtonian",
                    true
                )
    # physical constant
    g     = 9.81
    # number of points
    d = Array(CSV.read(path,DataFrame,header=false; delim="\t", limit=6))
    Δx= Float64(d[5])
    Δy= Δx
    z = Array(CSV.read(path,DataFrame,header=false; delim=" ", skipto=8)[:,2:end])
    z = (z[1:end,180:end])'
    nx,ny = size(z)
    xc= 0.0:Δx:(nx-1)*Δx
    yc= 0.0:Δy:(ny-1)*Δy

    xId = findall(x->x>xm[1] && x<xm[2],xc)
    yId = findall(x->x>ym[1] && x<ym[2],yc)

    z0    = copy(z[xId,yId])

    nx,ny = size(z0)
    xc0   = 0.0:Δx:(nx-1)*Δx
    yc0   = 0.0:Δy:(ny-1)*Δy

    h     = 1.0e-6.*ones(Float64,nx,ny)
    Qx    = zeros(Float64,nx,ny)
    Qy    = zeros(Float64,nx,ny)
    # action
    CFL   = 0.5
    if isViz == true
        svSolver_D(xc0,yc0,h,Qx,Qy,z0,g,CFL,T,tC,maximum(xc),maximum(yc),Δx,Δy,nx,ny,Dsim)
    elseif isViz == false
        svSolverPerf_D(xc0,yc0,h,Qx,Qy,z0,g,CFL,T,tC,maximum(xc),maximum(yc),Δx,Δy,nx,ny,Dsim)
    end
end
# https://techytok.com/lesson-parallel-computing
# https://nbviewer.org/github/daniel-koehn/Differential-equations-earth-system/blob/master/10_Shallow_Water_Equation_2D/01_2D_Shallow_Water_Equations.ipynb
# "runoff_D("C:/Users/Terranum/Dropbox/Jobs/_CREALP/numeric/nD_code/dat/dtm_5m/dsm_sion.asc",(0.0,2*1200.0),(0.0,2*1200.0),3600.0,600.0,true)"