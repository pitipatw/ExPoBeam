δϵc = 100e-6

#let's start with a rectangular section

b = 200.0 # [mm] width of the section
h = 400.0 # [mm] height of the section
L = 2000.0 # [mm] length of the section
nL = 10
dL = L/nL
setL = 0:L/nL:L # [mm] distance from the left end of the section

println("There are ", nL, " elements")
Es = 200_000
as = 50.0 # [mm2] area of the steel
#create a function to visualize sub-sections.


#

#at each distance, get moment values.
#a function that input distance, output moment value
function momentval(x::Float64)
    if x <500.0
        moment = 500.0
    elseif x <= 2000.0
        moment = 500.0 - (x-500.0)/(2000.0-500.0)*500.0
    else
        moment = 0.0
        println("check x = ", x)
    end
    return moment
end
#a function for concrete strain value
# 1956 equation by Smith and Young
#Smith, G.M.; Young, L.E. Ultimate flexural analysis on stress-strain curves for cylinders. ACI J. Proc. 1956, 53, 597–609.
function σc(ϵ::Float64;fc′::Float64 = 28.0, ϵ0::Float64 = 0.003 )
    σ = fc′/ϵ0*exp(1-ϵ/ϵ0)
    return σ
end




# f1 = Figure(resolution = (800,600))
# ax1 = Axis(f1[1,1], xlabel = "Distance [mm]", ylabel = "Moment [Nmm]")
# scatter!(ax1, setL, momentval.(setL), label = "Moment")

#Check the cocnret and steel stress/strain curve.
x =  0:0.0001:0.005
f2 = Figure(resolution = (800,600))
ax1 = Axis(f2[1,1], xlabel = "Strain", ylabel = "Stress")
plot!(ax1,x,σc.(x) , label = "Concrete")



#initial state calculation
#deadload, post tension force.
fpe = 200.0 #MPa
force = fpe * as

#we can get tendon position at each distance. 
tendon_pos = tendonprofile() # [mm] distance from the bottom of the section


ϵc_old = 0.0
tol = 1e-6
while abs(total_ϵc - δf) < tol
    ϵc_mid += δϵc
#section should have started at the middle.
total_ϵc == δf 
for l in setL #moment equilibrium in each sub section
    moment = momentval(l)
    tol = 1e-6
    ϵci = ϵc_old 

    #moment equilibrium

    ϵci += δϵc

    global δf = 0.0
    global c = 0
    checkforce = false
    while !checkforce
        global δf += δϵc
        fsteel = δf * Es * as
        @show global c = fsteel/(0.85*Ec*ϵci*b)

        if c > h
            println("Warning: c > h")
            checkforce = false
            break
        else
            checkforce = true
        end
    end

    println(c)
    println(δf)
    # println(moment)

end


as = 100.0 
d0 = 350.0




ϵc0 = 0.0 # [mm/mm] initial strain in the concrete
