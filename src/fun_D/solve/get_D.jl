@views function getUh_D(U,h,Qx,Qy,g,nx,ny,switch)
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
@views function setUFS_D(UFS,nx,ny)
    # index initialization
    i = (blockIdx().x-1)*blockDim().x+threadIdx().x
    j = (blockIdx().y-1)*blockDim().y+threadIdx().y
    # calculation
    if i<=nx && j<=ny
        k=1
            UFS[i,j,1,k] = 0.0
            UFS[i,j,2,k] = 0.0
            UFS[i,j,3,k] = 0.0
        k=2
            UFS[i,j,1,k] = 0.0
            UFS[i,j,2,k] = 0.0
            UFS[i,j,3,k] = 0.0
        k=3
            UFS[i,j,1,k] = 0.0
            UFS[i,j,2,k] = 0.0
            UFS[i,j,3,k] = 0.0
        k=4
            UFS[i,j,1,k] = 0.0
            UFS[i,j,2,k] = 0.0
            UFS[i,j,3,k] = 0.0
        k=5
            UFS[i,j,1,k] = 0.0
            UFS[i,j,2,k] = 0.0
            UFS[i,j,3,k] = 0.0
        k=6
            UFS[i,j,1,k] = 0.0
            UFS[i,j,2,k] = 0.0
            UFS[i,j,3,k] = 0.0
        k=7
            UFS[i,j,1,k] = 0.0
            UFS[i,j,2,k] = 0.0
            UFS[i,j,3,k] = 0.0
        #=
        for k \in 1:3 
            UFS[i,j,1,k] = 0.0
            UFS[i,j,2,k] = 0.0
            UFS[i,j,3,k] = 0.0
        end
        =#
    end
    return nothing
end