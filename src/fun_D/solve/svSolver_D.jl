@views function svSolver_D(xc,yc,h,Qx,Qy,z,g,CFL,T,tC,Δx,Δy,nx,ny,Dsim)
    solv_type  = Dsim.solv_type
    make_gif   = Dsim.make_gif
    flow_type  = Dsim.flow_type
    pcpt_onoff = Dsim.pcpt_onoff
    println("[=> generating initial plots & exporting...")
    # display initial stuffs
    η0   = minimum(h.+z)
    zmin = minimum(z)
    ηmax0= maximum(h.+z)
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
        z_plot(xc,yc,z)
    savefig(path_plot*"plot_z_init.png")
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
        h_plot(xc,yc,h,maximum(h),nx,ny,0.0,flow_type)
    savefig(path_plot*"plot_h_init.png")
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
        free_surface_plot(xc,yc,h,z,η0,0.75*(ηmax0-η0),nx,ny,0.0)
    savefig(path_plot*"plot_eta_init.png")
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
        wave_plot(xc,yc,h,z,η0,(ηmax0-η0),nx,ny,0.0)
    savefig(path_plot*"plot_wave_height_init.png")
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
        profile_plot(xc,yc,h,z,zmin,10.0,nx,ny,0.0)
    savefig(path_plot*"plot_profile_init.png")   
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
        hs=hillshade(z,Δx,Δy,45.0,315.0,nx,ny)
        hillshade_plot(xc,yc,hs,45.0,315.0,0.75)
    savefig(path_plot*"plot_hillshade.png")
    @info "Figs saved in" path_plot

    # define grid & block sizes for kernel initialization
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
    Ubc_D = CUDA.zeros(Float64,nx+2,ny+2,3)
    UFS_D = CUDA.zeros(Float64,nx+1,ny+1,3,7)
    # (:,:,:,1) UL
    # (:,:,:,2) UR
    # (:,:,:,3) FL
    # (:,:,:,4) FR
    # (:,:,:,5) SL
    # (:,:,:,6) SR
    # (:,:,:,7) F
    z_D   = CUDA.zeros(Float64,nx,ny)
    zbc_D = CUDA.zeros(Float64,nx+2,ny+2)
    copyto!(z_D,z)
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
        temp = Array(h_D)
        h_plot(xc,yc,temp,maximum(temp),nx,ny,0.0,flow_type)
    savefig(path_plot*"plot_h_init_GPU.png")
    # set time
    t     = 0.0
    # plot & time stepping parameters
    it    = 0
    ctr   = 0
    # generate GIF
    if make_gif==true
        println("[=> initializing & configuring .gif...")
        anim = Animation()
    end
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
        souSolve_D(cublocks,cuthreads,h_D,Qx_D,Qy_D,z_D,U_D,g,Δx,Δy,t,Δt,nx,ny,flow_type,pcpt_onoff)
        # update current time
        t  += Δt
        it += 1
        if t > ctr*tC
            ctr+=1
                fig=gr(size=(2*250,2*125),markersize=2.5)       
                    #fig=wave_plot(xc,yc,h,z,η0,0.1*ηmax0,nx,ny,t)
                    #fig=free_surface_plot(xc,yc,h,z,η0,0.25*(maximum(h.+z)-η0),nx,ny,t)
                    #fig=discharge_plot(xc,yc,h,Qx,Qy,z,2.5,nx,ny,t)
                    #fig=profile_plot(xc,yc,h,z,zmin,10.0,nx,ny,t)
                    fig=h_plot(xc,yc,Array(h_D),0.5,nx,ny,t,flow_type)
                    if make_gif==true
                        frame(anim,fig)
                    end
        end
        next!(prog;showvalues = [("[nx,ny]",(nx,ny)),("iteration(s)",it),("(✗) t/T",round(t/T,digits=2))])
    end
    ProgressMeter.finish!(prog, spinner = '✓',showvalues = [("[nx,ny]",(nx,ny)),("iteration(s)",it),("(✓) t/T",1.0)])
        #==#
    println("[=> generating final plots, exporting & exiting...")
    if make_gif==true
        gif(anim,path_plot*solv_type*".gif")
    end
    savefig(path_plot*solv_type*"_plot.png")

    free_surface_plot(xc,yc,h,z,η0,0.3*(maximum(h.+z)-η0),nx,ny,t)
    savefig(path_plot*solv_type*"_freesurface.png")

    println("[=> done! exiting...")
    return nothing
end
@views function svSolverPerf_D(xc,yc,h,Qx,Qy,z,g,CFL,T,tC,Δx,Δy,nx,ny,Dsim)
    solv_type  = Dsim.solv_type
    make_gif   = Dsim.make_gif
    flow_type  = Dsim.flow_type
    pcpt_onoff = Dsim.pcpt_onoff
    println("[=> plotting & saving initial geometry & conditions...")
    # display initial stuffs
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
        z_plot(xc,yc,z)
    savefig(path_plot*"plot_z_init.png")
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
        hs=hillshade(z,Δx,Δy,45.0,315.0,nx,ny)
        hillshade_plot(xc,yc,hs,45.0,315.0,0.75)
    savefig(path_plot*"plot_hillshade.png")
    @info "Figs saved in" path_plot
    savedData=DataFrame("x"=>vec(xc))
    CSV.write(path_save*"x.csv",savedData)
    savedData=DataFrame("y"=>vec(yc))
    CSV.write(path_save*"y.csv",savedData)
    savedData=DataFrame("z"=>vec(z),"hs"=>vec(hs))
    CSV.write(path_save*"zhs.csv",savedData)  

    # define grid & block sizes for kernel initialization
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
    Ubc_D = CUDA.zeros(Float64,nx+2,ny+2,3)
    UFS_D = CUDA.zeros(Float64,nx+1,ny+1,3,7)
    # (:,:,:,1) UL
    # (:,:,:,2) UR
    # (:,:,:,3) FL
    # (:,:,:,4) FR
    # (:,:,:,5) SL
    # (:,:,:,6) SR
    # (:,:,:,7) F
    z_D   = CUDA.zeros(Float64,nx,ny)
    zbc_D = CUDA.zeros(Float64,nx+2,ny+2)
    copyto!(z_D,z)
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
        temp = Array(h_D)
        h_plot(xc,yc,temp,maximum(temp),nx,ny,0.0,flow_type)
    savefig(path_plot*"plot_h_init_GPU.png")
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
        souSolve_D(cublocks,cuthreads,h_D,Qx_D,Qy_D,z_D,U_D,g,Δx,Δy,t,Δt,nx,ny,flow_type,pcpt_onoff)
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
        next!(prog;showvalues = [("[nx,ny]",(nx,ny)),("iteration(s)",it),("(✗) t/T",round(t/T,digits=2))])
    end
    ProgressMeter.finish!(prog, spinner = '✓',showvalues = [("[nx,ny]",(nx,ny)),("iteration(s)",it),("(✓) t/T",1.0)])
    param=DataFrame("nx"=>nx,"ny"=>ny,"dx"=>Δx,"dy"=>Δy,"t"=>T,"CFl"=>CFL,"nsave"=>ctr-1)
    CSV.write(path_save*"parameters.csv",param)
    @info "Data saved in" path_save  
    println("[=> done! exiting...")
    return nothing
end