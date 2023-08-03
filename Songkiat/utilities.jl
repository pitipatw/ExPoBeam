using CSV,  DataFrames
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


    return df[!,2]
end


