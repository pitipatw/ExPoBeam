# This code is for analyzing linear elastic "cracked" section 
# and potentially nonlinear creacked section as well.
"""
Adopted from 
    "Flexural behavior of externally prestressed beams Part 1: Analytical models"
    Chee Khoon Ng, Kiang Hwee Tan.
"""
# Setting up packages
using CSV, DataFrames
using UnPack
using Makie, GLMakie 

# Setting up the data
begin
    include("input_data.jl")
    include("functions.jl")
    include("Interpolations.jl")
end

# from the paper
# Since sections are usually under-reinforced, the behavior will govern by the steel yielding. 
# Therefore, the nonlinear behavior of the concrete is neglected.

# ..........Notes..........
# Use Ld = Ls (this test only) 
# Eccentricities measured from the neutral axis
# M is the moment in the constant region
# Mg = moment due to the selfweight
# M(x) is the moment equation due to the load
# Units N, mm, MPa


#iteration procedure starts here. 

#setup test values
begin
    st = 10.0 #step size of the force  inputs
    P_lb = 0:st:8300  #[lb] (This is based on the test data)
    P_N  = 4.448*P_lb # [N]
    P = P_N # This depends on what unit you want to use in the calculation.
    M = P*Ls/2.0 #given M inputs
end

#set up history containers
begin
    lenP = length(P)
    fps_history = zeros(length(P))
    dps_history = zeros(length(P))
    Icr_history = zeros(length(P))
    Ie_history  = zeros(length(P))
    c_history   = zeros(length(P))
    dis_history = zeros(length(P))
    dis_dev_history = zeros(length(P))
    fc_history  = zeros(length(P))
end
#Assume
begin
    Icr = Itr
    fps = fpe
    dps = dps0
    Ω =  getOmega(Sec)
    #we could do Mcr = 0 , becuase we crack at the begining anyway. 
    Mcr = getMcr(Mat, Sec, f, Ω)
    # Mcr = 0.00001
    # Mcr = 10.0
    Ie = Itr
end

#These lines just to make the variables global
begin
    Ωc = 0
    c  = 0
    Ac_req  = 0 
    Lc = 0
    fc = 0.0
    δ_mid = 0
    δ_dev = 0
    fc = 0.0
    Mi = 0
end

begin
    fig1 = Figure(backgroundcolor = RGBf(0.98,0.98,0.98) , resolution = (1500, 1500))
    fig2 = Figure(backgroundcolor = RGBf(0.98,0.98,0.98) , resolution = (2000, 1500))
    ga = fig1[1,1] = GridLayout()
    # gb = fig1[1,2] = GridLayout()
    gb = fig2[1,1] = GridLayout()
    title_name1 = [ "dps", "fps", "DisMid", "c", "Inertia(Crack(blue), eff(red))"] 
    title_name2 = [ "Original", "Shifted by Moment crack"]
    fig_monitor = Figure(resolution = (1200, 2000))
    x1 = ["P [N]", "P [N]", "P [N]", "P [N]", "P [N]"]
    y1 = ["dps [mm]", "fps [MPa]", "DisMid [mm]", "c [mm]", "Inertia [mm4]"]
    x2 = ["Displacement [mm]", "Displacement [mm]"]
    y2 = ["P [N]", "P [N]"]
end

axis_monitor1 = [Axis(ga[i,1], title = title_name1[i],ylabel = y1[i], xlabel = x1[i]) for i in 1:5]
axis_monitor2 = [Axis(gb[i,1],title = title_name2[i],ylabel = y2[i], xlabel = x2[i], yticks = -400000.:2500:40000)  for i in 1:2]


# workflow follows fig 7 in the paper.
conv1 = 1
counter1 = 0
counter2 = 0
for i in eachindex(M)
    Mi = M[i] 
    Lc = getLc(Sec,Mcr,Mi)
    # Lc = L/2
    # println(Lc)
    # break
    counter1 = 0
    conv1 = 1
    while conv1 > 1e-6
        counter1 += 1 
        if counter1 > 1000
            println("Warning: 1st iteration did not converge")
            break
        end
        # println("HI")
        #assume value of Itr and fps

        conv2 = 1
        counter2 = 0
        while conv2 > 1e-6
            # println("counter")
            counter2 += 1 
            if counter2 > 1000
                println("Warning: 2nd iteration did not converge")
                break
            end
            Ωc = getΩc(Ω, Icr, Lc, Sec)
            # ps_force_i = Aps*fps

            c = 10.0 #dummy
            conv_c = 1 
            counter_c = 0 
            while conv_c > 1e-6 
                counter_c += 1
                if counter_c > 1000
                    println("Warning: 3rd iteration did not converge")
                    break
                end
                #centroid of concrete area might not be at c/2
                Ac_req = Mi/(dps-c/2)/(0.85*fc′)
            
                # Ac_req = ps_force_i /0.85/fc′
                new_c = get_C(Ac_req)
                conv_c = abs(new_c - c)/new_c
                c = new_c
            end
            #calculate Icr
            Icr_calc = get_Icrack(c)

            conv2 = abs(Icr_calc - Icr)/Icr_calc

            Icr = Icr_calc
            
        end
       
        # println("Icr = ", Icr)
        # println("Ac_req ", Ac_req)
        # println("c: ", c)
        # @show Mcr , Mdec, Mi , Icr, Itr
        Ie = getIe(Mcr, Mdec, Mi, Icr, Itr)
        # println("Ie/Icr" , Ie/Icr)
        δ_mid, δ_dev , e  = getDelta(Mat, Sec, f, Ie, Mi, em,fps)
        dps = dps0 - (δ_mid - δ_dev)
        fc = fps/Eps*c/(dps-c) + Mi/Itr*c
        # println("fc: ", fc)
        # @assert fc <= 0.003
        fps_calc = getFps2(Mat, Sec, f , Ωc, c, dps, fc)
        conv1 = abs(fps_calc - fps) / fps
        fps = fps_calc
        #plot convergence of fps, icr and dps using Makie

    end

    # δmid = getDeltamid()
    #record the history
    fps_history[i] = fps
    dps_history[i] = dps
    Icr_history[i] = Icr
    Ie_history[i]  = Ie
    c_history[i]   = c
    dis_history[i] = δ_mid
    fc_history[i]  = fc
    dis_dev_history[i] = δ_dev
end

scatter!(axis_monitor1[1], P, dps_history, color = :red)
scatter!(axis_monitor1[2], P, fps_history, color = :red)
# scatter!(axis_monitor1[2], P, fc_history, color = :blue)
scatter!(axis_monitor1[3], P, dis_history, color = :red)
# scatter!(axis_monitor1[3], P, dis_dev_history, color = :blue)
scatter!(axis_monitor1[4], P, c_history, color = :red)
scatter!(axis_monitor1[5], P, Ie_history, color = :red ,label = "Ie")
scatter!(axis_monitor1[5], P, Icr_history, color = :blue, label= "Icr")
#add verticle line on each plot for Mcr
for i in 1:5
    vlines!(axis_monitor1[i], [Mcr*2/Ls], color = :black, label = "Mcr", linewidth = 5)
    #add verticle line for Mdec
    vlines!(axis_monitor1[i], [Mdec*2/Ls], color = :green, label = "Mdec")

end

#add legend

# elem_1 = [LineElement(color = :green, linestyle = nothing)]
# elem_2 = [LineElement(color = :red, linestyle = nothing)]
# leg = Legend(fig1[3, 1],[elem_1, elem_2],["Mdec", "Mcr"], patchsize = (35, 35))
# leg.tellheight = true
fig1

#compare the result with the test data.
begin
df = CSV.File(joinpath(@__DIR__,"pixelframe_beam1.csv"))
df = DataFrame(df)
test_P = df[!,2]
test_d = df[!,3]

# convert to in to mm
test_d = test_d .* 25.4

test_P = test_P .* 4.44822

# figure2 = Figure(resolution = (800, 600))
# ax1 = Axis(figure2[1, 1], ylabel = "Load [lb]", xlabel = "Displacement [in]")
# ax2 = Axis(figure2[2, 1], ylabel = "fps[MPa]", xlabel = "Displacement [in]")

plot!(axis_monitor2[1],dis_history[1:end],P[1:end], label = "calc", color = :blue)
plot!(axis_monitor2[1],test_d,test_P, label = "test", color = :red)

plot!(axis_monitor2[2],dis_history[1:end],P[1:end].-Mcr*2/Ls, label = "calc", color = :blue)
plot!(axis_monitor2[2],test_d,test_P, label = "test", color = :red)
# display(fig_monitor)


fig3 = Figure(resolution = (800, 600))
ax3 = Axis(fig3[1, 1], ylabel = "Force Diff [N]", xlabel = "Displacement [mm]")
plot!(ax3,dis_history[1:end],P[1:end].-Mcr*2/Ls, label = "calc", color = :blue)
plot!(axis_monitor2[2], dis_history, dis_history.*1000, label = "dis/1000", color = :green, markersize = 1)
#plot 

end
display(fig1)
display(fig2)
display(fig3)
save(joinpath(@__DIR__,"fig1_test.png"), fig1)
save(joinpath(@__DIR__,"fig2_test.png"), fig2)