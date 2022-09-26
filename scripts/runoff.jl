@views function runoff(path::String,xm::Tuple,ym::Tuple)
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
    T     = 60.0*60.0
    tC    = 600.0
    svSolverPerf(xc0,yc0,h,Qx,Qy,z0,g,CFL,T,tC,Δx,Δy,nx,ny,Dsim)
end
@views function runoff_D(path::String,xm::Tuple,ym::Tuple)
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
    T     = 60.0*60.0
    tC    = 600.0
    svSolverPerf_D(xc0,yc0,h,Qx,Qy,z0,g,CFL,T,tC,Δx,Δy,nx,ny,Dsim)
end
# https://techytok.com/lesson-parallel-computing
# https://nbviewer.org/github/daniel-koehn/Differential-equations-earth-system/blob/master/10_Shallow_Water_Equation_2D/01_2D_Shallow_Water_Equations.ipynb
# "runoff_D("C:/Users/crealp/Desktop/manu_GPU/dat/dtm_1m/dsm_sion.asc",(0.0,600.0),(0.0,600.0))"