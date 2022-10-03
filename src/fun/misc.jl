struct param
    solv_type::String
    make_gif::Bool
    flow_type::String
    pcpt_onoff::Bool
end

@views function __iniPlots(xc,yc,z,h,Δx,Δy,nx,ny,flow_type)
    η0   = minimum(h.+z)
    zmin = minimum(z)
    ηmax0= maximum(h.+z)
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
        z_plot(xc,yc,z)
    savefig(path_plot*"z0.png")
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
        h_plot(xc,yc,h,maximum(h),nx,ny,0.0,flow_type)
    savefig(path_plot*"h0.png")
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
    #    free_surface_plot(xc,yc,h,z,η0,0.75*(ηmax0-η0),nx,ny,0.0)
    #savefig(path_plot*"plot_eta_init.png")
    #gr(size=(2*250,2*125),legend=true,markersize=2.5)
    #    wave_plot(xc,yc,h,z,η0,(ηmax0-η0),nx,ny,0.0)
    #savefig(path_plot*"plot_wave_height_init.png")
    #gr(size=(2*250,2*125),legend=true,markersize=2.5)
    #    profile_plot(xc,yc,h,z,zmin,10.0,nx,ny,0.0)
    #savefig(path_plot*"plot_profile_init.png")   
    gr(size=(2*250,2*125),legend=true,markersize=2.5)
        hs=hillshade(z,Δx,Δy,45.0,315.0,nx,ny)
        hillshade_plot(xc,yc,hs,45.0,315.0,0.75)
    savefig(path_plot*"hillshade.png")
end
@views function __iniData(xc,yc,z,hs,nx,ny,Δx,Δy,T,CFL)
    savedData=DataFrame("x"=>vec(xc))
    CSV.write(path_save*"x.csv",savedData)
    savedData=DataFrame("y"=>vec(yc))
    CSV.write(path_save*"y.csv",savedData)
    savedData=DataFrame("z"=>vec(z),"hs"=>vec(hs))
    CSV.write(path_save*"zhs.csv",savedData)  
    param=DataFrame("nx"=>nx,"ny"=>ny,"dx"=>Δx,"dy"=>Δy,"t"=>T,"CFl"=>CFL)
    CSV.write(path_save*"parameters.csv",param)
end