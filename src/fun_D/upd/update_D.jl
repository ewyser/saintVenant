@views function U!_D(h,Qx,Qy,U,UFS,c,nx,ny,dim)
    # index initialization
    i  = (blockIdx().x-1)*blockDim().x+threadIdx().x
    j  = (blockIdx().y-1)*blockDim().y+threadIdx().y
    if dim==1 && i<=nx && j<=ny 
        U[i,j,1]-=c*((UFS[i+1,j  ,1,7].+UFS[i+1,j  ,1,6]).-(UFS[i,j,1,7].+UFS[i,j,1,5]))
        U[i,j,2]-=c*((UFS[i+1,j  ,2,7].+UFS[i+1,j  ,2,6]).-(UFS[i,j,2,7].+UFS[i,j,2,5]))
        U[i,j,3]-=c*((UFS[i+1,j  ,3,7].+UFS[i+1,j  ,3,6]).-(UFS[i,j,3,7].+UFS[i,j,3,5]))
        h[i,j]   = U[i,j,1] 
        Qx[i,j]  = U[i,j,2]
        Qy[i,j]  = U[i,j,3]
    elseif dim==2 && i<=nx && j<=ny
        U[i,j,1]-=c*((UFS[i  ,j+1,1,7].+UFS[i  ,j+1,1,6]).-(UFS[i,j,1,7].+UFS[i,j,1,5]))
        U[i,j,2]-=c*((UFS[i  ,j+1,2,7].+UFS[i  ,j+1,2,6]).-(UFS[i,j,2,7].+UFS[i,j,2,5]))
        U[i,j,3]-=c*((UFS[i  ,j+1,3,7].+UFS[i  ,j+1,3,6]).-(UFS[i,j,3,7].+UFS[i,j,3,5]))
        h[i,j]   = U[i,j,1] 
        Qx[i,j]  = U[i,j,2]
        Qy[i,j]  = U[i,j,3]
    end
    return nothing
end
@views function advU!_D(h,Qx,Qy,U,S,Δt,nx,ny,type)
    # index initialization
    i  = (blockIdx().x-1)*blockDim().x+threadIdx().x
    j  = (blockIdx().y-1)*blockDim().y+threadIdx().y
    if type==1 && i<=nx && j<=ny
        U[i,j,1]+=Δt*S[i,j,1]
        U[i,j,2]+=Δt*S[i,j,2]
        U[i,j,3]+=Δt*S[i,j,3]
        h[i,j]   = U[i,j,1] 
        Qx[i,j]  = U[i,j,2]
        Qy[i,j]  = U[i,j,3]
    elseif type==2 && i<=nx && j<=ny
        U[i,j,1]+=Δt*S[i,j,1]
        U[i,j,2]/=(1.0+Δt*S[i,j,2])
        U[i,j,3]/=(1.0+Δt*S[i,j,3])
        h[i,j]   = U[i,j,1] 
        Qx[i,j]  = U[i,j,2]
        Qy[i,j]  = U[i,j,3]
    end
    return nothing
end
