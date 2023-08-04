δϵc = 100e-6

#let's start with a rectangular section

b = 200.0 # [mm] width of the section
h = 400.0 # [mm] height of the section
L = 2000.0 # [mm] length of the section
nL = 10 #10-30 is recommended by Alkhairi (1991) where 1 is at the mid span.
dL = L/nL
setL = 0:L/nL:L # [mm] distance from the left end of the section
inx = 1:1:nL

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

#Stress-strain curve of concrete (fc -ϵc) of concrete by Scott et al. (1982)
function getfc(ϵ::Float64 ; fc′::Float64 = 28.0)
    if ϵ <= 0.002
        fc  = fc′ * (2*ϵ/0.002 - (ϵ/0.002)^2)
    elseif ϵ > 0.002
        Z = 0.5 / ( ((3 + 0.29*fc′)/145*fc′ ) - 0.002)  
        fc = clamp( fc′ * ( 1 - Z*(ϵ-0.002)), 0.2-fc′, Inf )  # fc shall not be less than 0.2*fc′
    else
        println("Recheck ϵ")
    end

    return fc
end

#Stress-strain curve of steel (fs -ϵs) of steel by Menegotto and Pinto (1973)
function getfps(ϵ::Float64 ; 
    K::Float64 = 1.0618,
    Q::Float64 = 0.01174, 
    R::Float64 = 7.1344,
    fpy::Float64 = 1_585.,
    Eps::Float64 = 193_000.)
    #Constants are for Grade 270, 7-wire strands)
    
    ϵ_star = ϵ * Eps / K/fpy
    fps = ϵ*Eps*(Q + ( 1 - Q)/(1 + ϵ_star^R)^(1/R))

    return fps
end

#Check the cocnret and steel stress/strain curve.

# x1 =  0:0.00005:0.005
# x2 = 0:0.00005:0.5
# f2 = Figure(resolution = (800,600))
# ax1 = Axis(f2[1,1], xlabel = "Strain", ylabel = "Stress", title ="Concrete Stress-Strain Curve")
# ax2 = Axis(f2[1,2], xlabel = "Strain", ylabel = "Stress", title ="Steel Stress-Strain Curve")
# plot!(ax1,x1,getfc.(x1) , label = "Concrete")
# plot!(ax2,x2,getfps.(x2) , label = "Steel")
# f2
# save(joinpath(@__DIR__,"stress-strain.png"), f2)



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
