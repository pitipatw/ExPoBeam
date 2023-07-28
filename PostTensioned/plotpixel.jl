using Makie, GLMakie

include("pixelgeo.jl")
dx = 0.1
dy = 0.1
# dx = 0.05
# dy = 0.05
dxdy = dx * dy



L = 300.0
t = 30.0
Lc = 30.0
Acomp = 1000.0
CompDepth = 20.8
nodes = fullpixel(L, t, Lc)
y_top = maximum(nodes[:, 2])
# f4 = Figure(resolution = (800, 800))
# ax4 = Axis(f4[1, 1], xlabel = "x", ylabel = "y", aspect = DataAspect())#, aspect = DataAspect(), xgrid = false, ygrid = false)
# scatter!(ax4, nodes[:,1],nodes[:,2], color = :red )
# f4


points = fillpoints(nodes, dx, dy)

check = pointsinpixel(nodes, points)

f1 = Figure(resolution = (800, 800))
ax1 = Axis(f1[1, 1], xlabel = "x", ylabel = "y", aspect = DataAspect())#, aspect = DataAspect(), xgrid = false, ygrid = false)
p1 = scatter!(ax1, points[check[:,1],1],points[check[:,1],2], color = :green )
f1



p_inpoly = points[check, :];
top = maximum(p_inpoly[:, 2]);
area = dx * dy * size(p_inpoly)[1];
println("area: ", area);

chk = Vector{Bool}(undef, size(p_inpoly)[1]);
c_pos = top - CompDepth;
# @time for i =1:size(p_inpoly)[1]
#     x = p_inpoly[i,1]
#     y = p_inpoly[i,2]
#     if y>c_pos
#         chk[i] = true
#     else
#         chk[i] = false
#     end
# end
#Threads really helps the time by 4 times
Threads.@threads for i = 1:size(p_inpoly)[1]
    # x = p_inpoly[i,1]
    y = p_inpoly[i, 2]
    if y > c_pos
        chk[i] = true
    else
        chk[i] = false
    end
end

com_pts = p_inpoly[chk, :];

# f3 = Figure(resolution = (800,600))
# ax3 = Axis(f3[1,1,] , xlabel = "x", ylabel = "y", aspect = DataAspect())
# p3 = scatter!(ax3, p_inpoly[:,1], p_inpoly[:,2], color = :red, markersize = 2)
# f3
# p4 = scatter!(ax3, com_pts[:,1], com_pts[:,2], color = :green, markersize = 1)
# f3



# a function that calculates the center of gravity and inertia of a given polygon respected to a line.

c_pos = 0.0; #this is not the depth, center
eval_pts = points[check, :];
# f3 = Figure(resolution = (800,600))
# ax3 = Axis(f3[1,1], xlabel = "x", ylabel = "y", aspect = DataAspect())
# ax4 = Axis(f3[1,2], xlabel = "x", ylabel = "y", aspect = DataAspect())
# p3 = scatter!(ax3, points[:,1], points[:,2], color = :red, markersize = 2)
# p4 = scatter!(ax4, eval_pts[:,1], eval_pts[:,2], color = :blue, markersize = 2)
# f3

(I, cgy) = secprop(eval_pts, c_pos, dx=dx, dy=dy);
println("I: ", I);
println("cgy: ", cgy);

Area = size(p_inpoly)[1] * dxdy;


(depth, chkd) = getdepth(p_inpoly, Acomp, nodes,tol = 0.005);
println("Depth is: ", depth)

compnodes = p_inpoly[chkd,:];
@show Ic, cgyc = secprop(compnodes, 0.0)
@show IcNA , cgyc2 = secprop(compnodes, cgyc)
