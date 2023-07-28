using CSV
using DataFrames

# main.jl is a file containing another function called sampleme() which samples the domain
# Inside main.jl, there are other files that are included, such as pixelgeo.jl and ptFunc.jl,
# which contain functions requires for sampleme() to run.

include("main.jl")

"""
Notations

s_{variable name} indicates a "set" of variables
input units are in N and mm
output units are in kN and m

fc′ : concrete strength (x1)
aps : area of the reinforcement (x2)
L : Pixel's length (x3)
t : Pixel's thickness (x4)
Lc : Pixel's cover (x5)
fpe : effective prestress (x6)
e : eccentricity (as a percentage of L) (x7)
l : beam length (x8)
baydepth : baysize (x9)
fR1 : fiber parameters (x10)
fR3 : fiber parameters (x11)

"""

# I could create pixel geometry first, then sample them, so we dont have to keep creating pixel geometry for each sample.


# s_fc′ = 28.0:2.0:56.0
# s_aps = 100.0:100.0:1000.0
# s_fpe = 100.0:50.0:1000.0
# s_e = 0.5:0.1:1.2


s_l = [4000.0]
s_baydepth = 1000.0
s_fR1 = [4.0]
s_fR3 = [3.5]



#simpler version
s_fc′ = [28.0 35.0 45.0 56.0]
s_aps = [100.0 500.0 1000.0]
s_L = [200.0]
s_t = [20.0]
s_Lc = [10.0]
s_fpe = [100.0 500.0]
s_e = [0.75]

#A length of the vector of parameters
# nsam_pts = size(s_fc′)[2]*size(s_aps)[2]*size(s_L)[2]*size(s_t)[2]*size(s_Lc)[2]*size(s_fpe)[2]*size(s_e)[2]*size(s_fR1)[2]*size(s_fR3)[2]
nsam_pts = length(s_fc′) * length(s_aps) * length(s_L) * length(s_t) * length(s_Lc) * length(s_fpe) * length(s_e) * length(s_fR1) * length(s_fR3)

#TODO : create combinations of these parameters in a matrix
#Predefined vector to be stored.
val = zeros(nsam_pts, 11)
res = zeros(nsam_pts, 3)
checkres = zeros(nsam_pts, 1)

#loop sampling space.
global counter = 0 
@time for L in s_L
    for t in s_t
        for Lc in s_Lc
            nodes = fullpixel(L, t, Lc)
            for x1 in s_fc′
                println("fc′: ", x1)
                for x2 in s_aps
                    for x6 in s_fpe
                        for x7 in s_e
                            for x10 in s_fR1
                                for x11 in s_fR3
                                    counter += 1
                                    #this is currently under my workaround to get it faster so it's kinda messy + werid notations
                                    #It should be x1 - x9 .
                                    val[counter, 1] = x1
                                    val[counter, 2] = x2
                                    val[counter ,3] = L
                                    val[counter ,4] = t
                                    val[counter ,5] = Lc
                                    val[counter, 6] = x6
                                    val[counter, 7] = x7
                                    val[counter, 8] = s_baydepth[1]
                                    val[counter, 9] = s_l[1]
                                    val[counter, 10] = x10
                                    val[counter, 11] = x11

                                    @show out = sampleme(x1, x2, nodes,L, x6, x7, s_l[1], s_baydepth[1], x10, x11)
                                    res[counter,:] .= out[1:3]
                                    # println(out[4])
                                    checkres[counter] = out[4]
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

#write output into CSV
dataall = hcat(val,res,checkres)
table1 = DataFrame(dataall, :auto)
CSV.write("output.csv", table1)

#parallel plot the result 

#Scatter plot the result.
