@views function τCoulomb_D!(S,U,z,g,nx,ny,Δx,Δy)
    # index initialization
    i = (blockIdx().x-1)*blockDim().x+threadIdx().x
    j = (blockIdx().y-1)*blockDim().y+threadIdx().y

    ρs = 2.7e3          # solid density
    ϕb = 35.0*pi/180    # internal friction angle
    μ0 = tan(ϕb)        # static friction coefficient
    μw = tan(0.5*ϕb)    # dynamic friction coefficient
    W  = 1.0e6          # velocity threshold
    if i<=nx && j<=ny
        S[i,j,1] = 0.0
        S[i,j,2] = 0.0
        S[i,j,3] = 0.0
        if U[i,j,1]>0.0
            u = U[i,j,2]/(U[i,j,1])   # x-component velocity
            v = U[i,j,3]/(U[i,j,1])   # y-component velocity
            w = sqrt(u^2+v^2)      # magnitude L2 of the velocity
            if w>0.0
                μ  = (μ0-μw)/(1.0+w/W)+μw   # velocity-dependent friction model, see yamada etal, 2018
                τ  = ρs*g*U[i,j,1]*μ        # basal frictional/shear resistance law, see 
                τx = τ*(u/w)        # x-component basal shear
                τy = τ*(v/w)        # y-component basal shear
            else 
                τx = 0.0
                τy = 0.0
            end
            S[i,j,1] = 0.0
            S[i,j,2] = -τx/ρs
            S[i,j,3] = -τy/ρs                   
        end
    end
    return nothing
end
@views function τNewtonian_D!(S,U,z,g,ϵp,nx,ny,Δx,Δy,pcpt_onoff)
    # index initialization
    i = (blockIdx().x-1)*blockDim().x+threadIdx().x
    j = (blockIdx().y-1)*blockDim().y+threadIdx().y

    n  = 0.00025
    ρw = 1.0e3
    if i<=nx && j<=ny
        S[i,j,1] = 0.0
        S[i,j,2] = 0.0
        S[i,j,3] = 0.0
        if U[i,j,1]>0.0
            u  = U[i,j,2]/(U[i,j,1])
            v  = U[i,j,3]/(U[i,j,1])
            w  = sqrt(u^2+v^2)
            if w>0.0
                    Cf = n^2*(U[i,j,1])^(-4/3)
                    τ  = g*Cf*w
            else 
                    τ  = 0.0
            end
            S[i,j,1] = ϵp*pcpt_onoff
            S[i,j,2] = τ
            S[i,j,3] = τ
        end
    end
    return nothing
end
@views function souSolve_D!(cublocks,cuthreads,h,Qx,Qy,S,U,z,g,Δx,Δy,t,Δt,nx,ny,flow_type,pcpt_onoff)
    if flow_type=="coulomb"
        @cuda blocks=cublocks threads=cuthreads τCoulomb_D!(S,U,z,g,nx,ny,Δx,Δy)
        synchronize()
        @cuda blocks=cublocks threads=cuthreads advU_D!(h,Qx,Qy,U,S,Δt,nx,ny,1)
        synchronize()
    elseif flow_type=="newtonian"
        ϵp = 8.0e-6
        @cuda blocks=cublocks threads=cuthreads τNewtonian_D!(S,U,z,g,ϵp,nx,ny,Δx,Δy,1)
        synchronize()
        @cuda blocks=cublocks threads=cuthreads advU_D!(h,Qx,Qy,U,S,Δt,nx,ny,2)
        synchronize()
    end
    return nothing
end