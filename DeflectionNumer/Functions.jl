using CSV, DataFrames
# using InverseFunctions

function checkeq(ϵc::Float64 , ϵs::Float64, m::Float64)
     #loop depth
     
    include("area2cg.csv")

    cg = 0.0 #that function 

    arm = cg - ds

    fsc = Es * ϵs * as
    moment = fsc*as*arm

    if abs(moment - m ) < 1e-6
        return true
    else
        return false
    end

end




function tendonprofile()
    #first method
    #read tendon profile from csv file
    #df = CSV.read("tendonprofile.csv", DataFrame)

    #second

    # return df[!,2]
    return -200.0
end

"""
get depth of the section given the area of the concrete
"""
function getdepth(ac::Float64)
    depth = ac/200.0

    return depth
end

"""
Stress-strain curve of concrete (fc -ϵc) by Scott et al. (1982)
Stress max at 0.003 at specified strength [MPa]
"""
function getfc(ϵ::Float64 ; fc′::Float64 = 35.0)
    if ϵ <= 0.002
        fc  = fc′ * (2*ϵ/0.002 - (ϵ/0.002)^2)
    elseif ϵ > 0.002
        Z = 0.5 / ( ((3 + 0.29*fc′)/145*fc′ ) - 0.002)  
        fc = clamp( fc′ * ( 1 - Z*(ϵ-0.002)), 0.2-fc′, Inf )  # fc shall not be less than 0.2*fc′
        # if ϵ > 0.003
        #     println("Recheck ϵ")
        # end
    else
        println("Recheck ϵ")
    end

    return fc
end

"""
use getfc to inversly find ϵc
"""
function getϵ(fc::Float64; fc′::Float64 = 35.0) 
    #brute force
    ϵdummy = 0.0:0.0000001:0.003
    fc_ϵ = getfc.(ϵdummy, fc′= fc′)
    ϵ = ϵdummy[findall(x-> abs(x-fc) < 1e-1, fc_ϵ)[1]]
    return ϵ
end

"""
Stress-strain curve of steel (fs -ϵs) of steel by Menegotto and Pinto (1973)
"""
function getfps(ϵ::Float64; 
    K::Float64 = 1.0618,
    Q::Float64 = 0.01174, 
    R::Float64 = 7.344,
    fpy::Float64 = 1_585.,
    Eps::Float64 = 193_000.)
    #Constants are for Grade 270, 7-wire strands)
    
    ϵ_star = ϵ * Eps / K / fpy
    fps = ϵ*Eps*(Q + ( 1 - Q)/(1 + ϵ_star^R)^(1/R))

    return fps
end



