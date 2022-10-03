struct param
    solv_type::String
    make_gif::Bool
    flow_type::String
    pcpt_onoff::Bool
end

@views function saved!(xc,yc,z,hs,nx,ny,Δx,Δy,T,CFL)
    savedData=DataFrame("x"=>vec(xc))
    CSV.write(path_save*"x.csv",savedData)
    savedData=DataFrame("y"=>vec(yc))
    CSV.write(path_save*"y.csv",savedData)
    savedData=DataFrame("z"=>vec(z),"hs"=>vec(hs))
    CSV.write(path_save*"zhs.csv",savedData)  
    param=DataFrame("nx"=>nx,"ny"=>ny,"dx"=>Δx,"dy"=>Δy,"t"=>T,"CFl"=>CFL)
    CSV.write(path_save*"parameters.csv",param)
end