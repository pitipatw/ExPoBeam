include("utilities.jl")

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
        moment = 200.0
    elseif x <= 2000.0
        moment = 200.0 - (x-500.0)/(2000.0-500.0)*200.0
    else
        moment = 0.0
        println("check x = ", x)
    end
    return moment
end

"""
Stress-strain curve of concrete (fc -ϵc) of concrete by Scott et al. (1982)
Stress max at 0003 at specified strength [MPa]
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
get \epsilon_c from f_c
"""
function getϵ(fc::Float64; fc′::Float64 = 35.0) 
    #brute force
    ϵdummy = 0.0:0.0000001:0.003
    fc_ϵ = getfc.(ϵdummy, fc′= fc′)
    ϵ = ϵdummy[findall(x-> abs(x-fc) < 1e-1, fc_ϵ)[1]]
    return ϵ
end

getfc(0.0025)
getϵ(28.)


"""
Stress-strain curve of steel (fs -ϵs) of steel by Menegotto and Pinto (1973)
"""
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
tendon_pos = tendonprofile() # [mm] distance from the centroid of the section
begin

#Assumption based on initial condition
ϵc_assump = δϵc # 
fpse_assump = 200.0 
df = fpse_assump/Es
tol = 1e-6
δf = df
ϵc_total = 0.003
δf_history = Vector{Float64}()
ϵc_history = Vector{Float64}()
global i = 1 # for tendon iteration
global k = 1 # for concrete iteration
global counter = 1
while true
    #force equilibrium
    global δf += δϵc
    
    fps = δf * Es
#Steel force
fsteel = fps * as
#0.85 - 0.65 based on the fc' value

#at the critical section
ac = fsteel/(0.85*getfc(ϵc_assump)) # [mm2] area of the concrete
c = getdepth(ac) #work on this measure from the extreme compressive fiber (top) 

#moment at the critical section 
d = 150.0 # [mm] distance from the extreme compressive fiber (top) to the centroid of tendon
mc = fsteel * (d-c) # [Nmm] moment at the critical section
# println(mc/1e6, " kNm")

ϵc_all = Vector{Float64}(undef, nL)
ϵc_all[1] = ϵc_assump
#get M from other places.
for i = 2:nL #middle point already calculated, so start from 2.
    mi = momentval(setL[i])
    di = tendon_pos #[i] #this might have to be updated more
    fsteel = fps * as
    arm = mi/fsteel
    cg = d - arm
    c = 2*cg 
    #get ac from c 
    ac =50.0*c
    @show fc = fsteel/(0.85*ac)


    # from c get a
    ϵc_top = getϵ(fc)
    ϵci = (di-c)/c*ϵc_top
    #at di, calculate the ϵci of that point
    ϵc_all[i] = ϵci
    # force should be equal here.
end

ϵc_total = sum(ϵc_all)
push!(ϵc_history, ϵc_total)
push!(δf_history, δf)
    global counter += 1

    if abs(ϵc_total - δf) < tol || counter > 1000
        break
    end

    @show δf = ϵc_total


end

    
end
    
    |ϵc_mid += δϵc


#section should have started at the middle.
total_ϵc == δf 
for l in setL #moment equilibrium in each sub section
    moment = momentval(l)
    tol = 1e-6
    ϵci = ϵc_initial 

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
