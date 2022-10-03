@views function svSolver_D(xc,yc,h,Qx,Qy,z,g,CFL,T,tC,lx,ly,Δx,Δy,nx,ny,Dsim)
    solv_type  = Dsim.solv_type
    make_gif   = Dsim.make_gif
    flow_type  = Dsim.flow_type
    pcpt_onoff = Dsim.pcpt_onoff
    println("[=> generating initial plots & exporting...")
    # display initial stuffs
    __iniPlots(xc,yc,z,h,Δx,Δy,nx,ny,flow_type)
    @info "Figs saved in" path_plot
    # define grid & block sizes for kernel launch parameters 
    BLOCKx    = 32
    BLOCKy    = 16
    GRIDx     = ceil(Int,(nx+2)/BLOCKx)
    GRIDy     = ceil(Int,(ny+2)/BLOCKy)
    cuthreads = (BLOCKx, BLOCKy, 1)
    cublocks  = (GRIDx,  GRIDy,  1)
    @info "GPU kernel:" cuthreads,cublocks nx,ny
    # allocate memory on GPU, i.e., variable on device specified by <nameOfVariable>_D
    h_D   = CUDA.zeros(Float64,nx,ny)
    copyto!(h_D,h)
    Qx_D  = CUDA.zeros(Float64,nx,ny)
    copyto!(Qx_D,Qx)
    Qy_D  = CUDA.zeros(Float64,nx,ny)
    copyto!(Qy_D,Qy)
    U     = zeros(Float64,nx,ny,3)
    U_D   = CUDA.zeros(Float64,nx,ny,3)
    S_D   = CUDA.zeros(Float64,nx,ny,3)    
    @cuda blocks=cublocks threads=cuthreads getUh_D(U_D,h_D,Qx_D,Qy_D,nx,ny,2)
    Ubc_D = CUDA.zeros(Float64,nx+2,ny+2,3)
    UFS_D = CUDA.zeros(Float64,nx+1,ny+1,3,7)
    z_D   = CUDA.zeros(Float64,nx,ny)
    copyto!(z_D,z)
    zbc_D = CUDA.zeros(Float64,nx+2,ny+2)
    # set time
    t     = 0.0
    # plot & time stepping parameters
    it    = 0
    ctr   = 0
    # action
    println("[=> action!")
    prog  = ProgressUnknown("working hard:", spinner=true,showspeed=true)
    while t<T
    	# adaptative Δt
        Δt  = getΔt(Array(h_D),Array(Qx_D),Array(Qy_D),g,Δx,Δy,CFL,nx,ny)
        # advection step solution
        advSolve_D(cublocks,cuthreads,h_D,Qx_D,Qy_D,UFS_D,Ubc_D,U_D,zbc_D,z_D,g,Δx,Δy,Δt,nx,ny,solv_type)
        # source step solution
        souSolve_D(cublocks,cuthreads,h_D,Qx_D,Qy_D,S_D,U_D,z_D,g,Δx,Δy,t,Δt,nx,ny,flow_type,pcpt_onoff)
        # update current time
        t  += Δt
        it += 1
        if t > ctr*tC
            fig=gr(size=(2*250,2*125),markersize=2.5)       
                fig=h_plot(xc,yc,Array(h_D),0.5,nx,ny,t,flow_type)
            ctr+=1
        end
        next!(prog;showvalues = [("[lx,ly]",(round(lx),round(ly))),("[nx,ny]",(nx,ny)),("iteration(s)",it),("(✗) t/T [%]",round(100.0*t/T,digits=1))])
    end
    ProgressMeter.finish!(prog, spinner = '✓',showvalues = [("[lx,ly]",(round(lx),round(ly))),("[nx,ny]",(nx,ny)),("iteration(s)",it),("(✓) t/T [%]",100.0)])
    println("[=> generating final plots, exporting & exiting...")
    savefig(path_plot*"hf_"*solv_type*"_D.png")
    println("[=> done! exiting...")
    return nothing
end
@views function svSolverPerf_D(xc,yc,h,Qx,Qy,z,g,CFL,T,tC,lx,ly,Δx,Δy,nx,ny,Dsim)
    solv_type  = Dsim.solv_type
    make_gif   = Dsim.make_gif
    flow_type  = Dsim.flow_type
    pcpt_onoff = Dsim.pcpt_onoff
    println("[=> plotting & saving initial geometry & conditions...")
    # display initial stuffs
    __iniPlots(xc,yc,z,h,Δx,Δy,nx,ny,flow_type)
    hs=hillshade(z,Δx,Δy,45.0,315.0,nx,ny)
    @info "Figs saved in" path_plot
    __iniData(xc,yc,z,hs,nx,ny,Δx,Δy,T,CFL)
    # define grid & block sizes for kernel launch parameters 
    BLOCKx    = 32
    BLOCKy    = 16
    GRIDx     = ceil(Int,(nx+2)/BLOCKx)
    GRIDy     = ceil(Int,(ny+2)/BLOCKy)
    cuthreads = (BLOCKx, BLOCKy, 1)
    cublocks  = (GRIDx,  GRIDy,  1)
    @info "GPU kernel:" cuthreads,cublocks nx,ny
    # allocate memory on GPU, i.e., variable on device specified by <nameOfVariable>_D
    h_D   = CUDA.zeros(Float64,nx,ny)
    copyto!(h_D,h)
    Qx_D  = CUDA.zeros(Float64,nx,ny)
    copyto!(Qx_D,Qx)
    Qy_D  = CUDA.zeros(Float64,nx,ny)
    copyto!(Qy_D,Qy)
    U     = zeros(Float64,nx,ny,3)
    U_D   = CUDA.zeros(Float64,nx,ny,3)
    S_D   = CUDA.zeros(Float64,nx,ny,3) 
    @cuda blocks=cublocks threads=cuthreads getUh_D(U_D,h_D,Qx_D,Qy_D,nx,ny,2)
    Ubc_D = CUDA.zeros(Float64,nx+2,ny+2,3)
    UFS_D = CUDA.zeros(Float64,nx+1,ny+1,3,7)
    z_D   = CUDA.zeros(Float64,nx,ny)
    copyto!(z_D,z)
    zbc_D = CUDA.zeros(Float64,nx+2,ny+2)
    # set time
    t     = 0.0
    # plot & time stepping parameters
    it    = 0
    ctr   = 0
    # action
    println("[=> action!")
    prog  = ProgressUnknown("working hard:", spinner=true,showspeed=true)
    while t<T
    	# adaptative Δt
        Δt  = getΔt(Array(h_D),Array(Qx_D),Array(Qy_D),g,Δx,Δy,CFL,nx,ny)
        #Δt  = getΔt(Array(h_D),Array(Qx_D),Array(Qy_D),g,Δx,Δy,CFL,nx,ny)
        # advection step solution
        advSolve_D(cublocks,cuthreads,h_D,Qx_D,Qy_D,UFS_D,Ubc_D,U_D,zbc_D,z_D,g,Δx,Δy,Δt,nx,ny,solv_type)
        # source step solution
        souSolve_D(cublocks,cuthreads,h_D,Qx_D,Qy_D,S_D,U_D,z_D,g,Δx,Δy,t,Δt,nx,ny,flow_type,pcpt_onoff)
        # update current time
        t  += Δt
        it += 1
        if t > ctr*tC
            savedData=DataFrame("h"=>vec(Array(h_D)),"Qx"=>vec(Array(Qx_D)),"Qy"=>vec(Array(Qy_D)))
            CSV.write(path_save*"hQxQy_"*string(ctr)*".csv",savedData)
            savedData=DataFrame("t"=>t,"Δt"=>Δt,"it"=>it)
            CSV.write(path_save*"tdt_"*string(ctr)*".csv",savedData)
            ctr+=1
        end
        next!(prog;showvalues = [("[lx,ly]",(round(lx),round(ly))),("[nx,ny]",(nx,ny)),("iteration(s)",it),("(✗) t/T [%]",round(100.0*t/T,digits=1))])
    end
    ProgressMeter.finish!(prog, spinner = '✓',showvalues = [("[lx,ly]",(round(lx),round(ly))),("[nx,ny]",(nx,ny)),("iteration(s)",it),("(✓) t/T [%]",100.0)])
    @info "Data saved in" path_save  
    println("[=> done! exiting...")
    return nothing
end

# UFS array reads as: (1:nx,1:ny,1:3,1:7) UL-UR-FL-FR-SL-SR,F
    # (:,:,:,1) UL
    # (:,:,:,2) UR
    # (:,:,:,3) FL
    # (:,:,:,4) FR
    # (:,:,:,5) SL
    # (:,:,:,6) SR
    # (:,:,:,7) F