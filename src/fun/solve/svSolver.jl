@views function svSolver(xc,yc,h,Qx,Qy,z,g,CFL,T,tC,lx,ly,Δx,Δy,nx,ny,Dsim)
    solv_type  = Dsim.solv_type
    make_gif   = Dsim.make_gif
    flow_type  = Dsim.flow_type
    pcpt_onoff = Dsim.pcpt_onoff
    println("[=> generating initial plots & exporting...")
    # display initial stuffs
    __ini_plots(xc,yc,z,h,Δx,Δy,nx,ny,flow_type)
    @info "Figs saved in" path_plot
    # set & get vectors
    U,F,G = getUF(h,Qx,Qy,g,nx,ny)
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
        Δt  = getΔt(h,Qx,Qy,g,Δx,Δy,CFL,nx,ny)
        # advection step solution
        h,Qx,Qy = advSolve(h,Qx,Qy,z,U,F,G,g,Δx,Δy,Δt,nx,ny,solv_type)
        # source step solution
        h,Qx,Qy = souSolve(h,Qx,Qy,z,U,g,Δx,Δy,t,Δt,nx,ny,flow_type,pcpt_onoff)
        # update current time
        t  += Δt
        it += 1
        if t > ctr*tC
            fig=gr(size=(2*250,2*125),markersize=2.5)       
                fig=h_plot(xc,yc,h,0.5,nx,ny,t,flow_type)
            ctr+=1    
        end
        next!(prog;showvalues = [("[lx,ly]",(round(lx),round(ly))),("[nx,ny]",(nx,ny)),("iteration(s)",it),("(✗) t/T [%]",round(100.0*t/T,digits=1))])
    end
    ProgressMeter.finish!(prog, spinner = '✓',showvalues = [("[lx,ly]",(round(lx),round(ly))),("[nx,ny]",(nx,ny)),("iteration(s)",it),("(✓) t/T [%]",100.0)])
    println("[=> generating final plots, exporting & exiting...")
    savefig(path_plot*"hf_"*solv_type*".png")
    println("[=> done! exiting...")
    return nothing
end
@views function svSolverPerf(xc,yc,h,Qx,Qy,z,g,CFL,T,tC,lx,ly,Δx,Δy,nx,ny,Dsim)
    solv_type  = Dsim.solv_type
    make_gif   = Dsim.make_gif
    flow_type  = Dsim.flow_type
    pcpt_onoff = Dsim.pcpt_onoff
    println("[=> plotting & saving initial geometry & conditions...")
    # display initial stuffs
    __ini_plots(xc,yc,z,h,Δx,Δy,nx,ny,flow_type)
    hs=hillshade(z,Δx,Δy,45.0,315.0,nx,ny)
    @info "Figs saved in" path_plot
    __saved(xc,yc,z,hs,nx,ny,Δx,Δy,T,CFL)
    # set & get vectors
    U,F,G = getUF(h,Qx,Qy,g,nx,ny)
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
        Δt  = getΔt(h,Qx,Qy,g,Δx,Δy,CFL,nx,ny)
        # advection step solution
        h,Qx,Qy = advSolve(h,Qx,Qy,z,U,F,G,g,Δx,Δy,Δt,nx,ny,solv_type)
        # source step solution
        h,Qx,Qy = souSolve(h,Qx,Qy,z,U,g,Δx,Δy,t,Δt,nx,ny,flow_type,pcpt_onoff)
        # update current time
        t  += Δt
        it += 1
        if t > ctr*tC
            savedData=DataFrame("h"=>vec(h),"Qx"=>vec(Qx),"Qy"=>vec(Qy))
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