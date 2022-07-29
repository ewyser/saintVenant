# include dependencies & function call(s)
include("../bc/getBCs.jl")
include("../flux/fluxes.jl")
# core function(s)
@views function updateU!(U,F,G,cx,cy,nx,ny,nD)
    for dim in 1:nD
        for j in 1:ny
            for i in 1:nx
                U[i,j,dim] -= cx*F[i,j,dim]
                U[i,j,dim] -= cy*G[j,i,dim]
            end
        end
    end
end
@views function advSolve(h,Qx,Qy,z,U,F,G,g,Δx,Δy,Δt,nx,ny,type)
    # assembly of conservative variables vector and flux function vector
        getU!(U,h,Qx,Qy,nx,ny)
    # ghost cells
        #2) periodic in x
        Ubc = getBCs(U,nx,ny,3,"reflective")
        zbc = getBCs(z,nx,ny,1,"dirichlet")          
    # find inter-cell fluxes (e.g., HLL fluxes or the Rusanov fluxes)
        fluxes!(F,Ubc,zbc,g,Δx,Δt,type,nx,ny,"x")
    # ghost cells    
        #2) periodic in y
        Ubc = getBCs(permutedims(U,(2,1,3)),ny,nx,3,"reflective")
        zbc = getBCs(permutedims(z,(2,1)  ),ny,nx,1,"dirichlet")
    # find inter-cell fluxes (e.g., HLL fluxes or the Rusanov fluxes)
        fluxes!(G,Ubc,zbc,g,Δy,Δt,type,ny,nx,"y")
    # update conservative variable vector
        updateU!(U,F,G,(Δt/Δx),(Δt/Δy),nx,ny,3)
    return copy(U[:,:,1]),copy(U[:,:,2]),copy(U[:,:,3])
end