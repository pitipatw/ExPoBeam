#calculating first part (from 3 parts) of the process. 
#loop section sn, step i
# for sn in 1:sn_all
# keep track fps by i
# keep track ϵc_top by k
ϵc_top_k = 0
d_deflected = 0.0
d0 = [-200.0]
#section number 
sn = 1

#what do we need to know
θ = 30.0
#current fps at this step
fps_i = 1000
#Concrete area
ac = 2000
#Steel area
as = 140
#stress from tendon at concrete
fps_c_i = fps_i*cosd(θ)
#compression strain from the tendon on concrete faces.
ϵc_fps = fps_c_i*as/ac
#Maximum concrete strain (from iteration)
ϵc_top_k += δϵc #iterate this will indicate the triangle. 
#Find the triangle. 
#need to know the depth of the tendon at this step
d_i = d0[sn] - d_deflected #let's this be on the global coordinate.
ϵs_i = fps_i/Es 

#now we can draw the traingle.
#y top of the cross section
y_top = 150.0
y_bot = -200.0
p1 = [ 0.0 , y_top ]
p2 = [ ϵc_top_k , y_top ]
p3 = [ -ϵs_i , d_i ]
p4 = [0.0, d_i]

triangle_pts = hcat(p1, p2 , p3 ,p4, p1)

#now, we integrate the forces, to check for equilibrium
#work on "mm"
force_T = as*fps_i
δy = 1
ys = y_bot:1:y_top
#vectorize this, so it can be paralleled.
force_C = Vector{Float64}(undef, size(ys))
# strips = interploation ? will see
for yy in eachindex(ys) 
    ypos = ys[yy]
    strip_i = strips(ypos) #area
    strain_at_y_pos = get from the triangle
    σ_i = getfc(strain)
    force_C_i = σ_i*strip_i
    force_Cp[ii] = force_C_i
    







trace = scatter(; x = triangle_pts[1,:] , y = triangle_pts[2,:])
plot(trace)
