using CSV,  DataFrames
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

