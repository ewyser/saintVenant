macro A(z) esc(:( $z[i-1,j-1] )) end
macro B(z) esc(:( $z[i-1,j  ] )) end
macro C(z) esc(:( $z[i-1,j+1] )) end

macro D(z) esc(:( $z[i  ,j-1] )) end
macro E(z) esc(:( $z[i  ,j  ] )) end
macro F(z) esc(:( $z[i  ,j+1] )) end

macro G(z) esc(:( $z[i+1,j-1] )) end
macro H(z) esc(:( $z[i+1,j  ] )) end
macro I(z) esc(:( $z[i+1,j+1] )) end

@views function hillshade(z,Δx,Δy,ϕ,θ,nx,ny)
    #=
    -------------
    | a | b | c |
    -------------
    | d | e | f | e = i,j
    -------------
    | g | h | i |
    -------------
    =#
    ϕ  = (90.0-ϕ)*pi/180.0
    θ  = (360.0-θ+90.0)*pi/180.0     
    hs = zeros(eltype(z),nx,ny)*NaN
    for j ∈ 2:ny-1
        for i ∈ 2:nx-1
            ∂zx = ((@C(z)+2.0*@F(z)+@I(z))-(@A(z)+2.0*@D(z)+@G(z)))/(8.0*Δx)
            ∂zy = ((@G(z)+2.0*@H(z)+@I(z))-(@A(z)+2.0*@B(z)+@C(z)))/(8.0*Δy)
            s   = atan(sqrt(∂zx^2+∂zy^2))
            if ∂zx != 0.0
                a = atan(∂zy,-∂zx)
                if a < 0
                    a = 2.0*pi+a 
                end
            end
            if ∂zx == 0.0
                if ∂zy > 0.0
                    a = pi/2.0
                elseif ∂zy < 0.0
                    a = 2.0*pi-pi/2.0
                else
                    a = atan(∂zy,-∂zx) 
                end
            end
            h = 255.0*((cos(ϕ)*cos(s))+(sin(ϕ)*sin(s)*cos(θ-a)))
            if h >= 0.0
                hs[i,j] = abs(1.0+h)
            else
                hs[i,j] = 1.0
            end
        end
    end
    return hs
end