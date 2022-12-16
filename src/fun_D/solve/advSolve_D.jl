@views function advSolve_D!(cublocks,cuthreads,h,Qx,Qy,UFS,Ubc,U,zbc,z,g,Δx,Δy,Δt,nx,ny,type)
    for dim ∈ 1:2 # dim ∈ [x,y]
        # assembly of conservative variables vector and flux function vector
        @cuda blocks=cublocks threads=cuthreads setUFS_D!(UFS,nx+1,ny+1)
        # ghost cells
        @cuda blocks=cublocks threads=cuthreads getBC_D!(zbc,Ubc,z,U,nx,ny,dim)
        # get fluxes dim-direction
        if type=="Rus"
            @cuda blocks=cublocks threads=cuthreads Rus_D!(UFS,Ubc,zbc,g,nx,ny,dim)
        elseif type=="HLL"
            @cuda blocks=cublocks threads=cuthreads HLL_D!(UFS,Ubc,zbc,g,nx,ny,dim)
        elseif type=="HLLC"
            @cuda blocks=cublocks threads=cuthreads HLLC_D!(UFS,Ubc,zbc,g,nx,ny,dim)
        else 
            @error "invalid numerical flux definition, valid ones are:\n\t a) Rus  - Rusanov fluxes\n\t b) HLL  - HLL approximate Riemann solver\n\t c) HLLC - HLLC  approximate Riemann solver"
            exit(-1)
        end
        # update along dim-direction
        @cuda blocks=cublocks threads=cuthreads U_D!(h,Qx,Qy,U,UFS,(Δt/Δx),nx,ny,dim)
        synchronize()
    end
end