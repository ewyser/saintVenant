@views function getUh_D!(U,h,Qx,Qy,nx,ny,switch)
    # index initialization
    i = (blockIdx().x-1)*blockDim().x+threadIdx().x
    j = (blockIdx().y-1)*blockDim().y+threadIdx().y
    # calculation
    if i<=nx && j<=ny
        if switch == 1
            h[i,j]  = U[i,j,1] 
            Qx[i,j] = U[i,j,2]
            Qy[i,j] = U[i,j,3]
        else
            U[i,j,1] = h[i,j]
            U[i,j,2] = Qx[i,j]
            U[i,j,3] = Qy[i,j]
        end

    end
    return nothing
end
@views function setUFS_D!(UFS,nx,ny)
    # index initialization
    i = (blockIdx().x-1)*blockDim().x+threadIdx().x
    j = (blockIdx().y-1)*blockDim().y+threadIdx().y
    # calculation
    if i<=nx && j<=ny
        for k ∈ 1:7 
            UFS[i,j,1,k] = 0.0
            UFS[i,j,2,k] = 0.0
            UFS[i,j,3,k] = 0.0
        end
    end
    return nothing
end
@views function getΔt_D(h,Qx,Qy,g,Δx,Δy,CFL,nx,ny)
    # find minimal Δt consistent with CFL
    cx = 0.0
    cy = 0.0
    Δ  = min(Δx,Δy)
    cx = findmax(abs.(Qx./h).+sqrt.(g.*h))
    cy = findmax(abs.(Qy./h).+sqrt.(g.*h))    
    return CFL*Δ/(max(cx[1],cy[1]))
end