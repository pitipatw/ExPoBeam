#integrate from points
using PolygonInbounds
nodes = [0. 0.; 0. 10.; 10.0 10.0 ;10. 0.;]
nodes = newnodes
A = 1/2*10*10
x = -2000.0:100.:2000.0
y = -2000:100:1500.0
points = Matrix{Float64}(undef, size(x)[1]*size(y)[1], 2)
for i =1:size(x)[1]
    for j = 1:size(y)[1]
        points[(i-1)*size(y)[1]+j,:] = [x[i], y[j]]
    end
end
edges = Matrix{Int64}(undef, size(nodes)[1], 2)
for i = 1:size(nodes)[1]
    if i != size(nodes)[1]
        edges[i,:] =  [i, i+1]
    else 
        edges[i,:] =  [i, 1]
    end
end
edges #must be int!
tol = 1e-1

stat = inpoly2(points, nodes, edges, atol =tol)

# f2 = Figure(resolution = (800, 600))
# ax2 = Axis(f2[1, 1], xlabel = "x", ylabel = "y", aspect = DataAspect())#, aspect = DataAspect(), xgrid = false, ygrid = false)
# # p2 = scatter!(ax2, ptx,pty, color = :red )
# @time for i = 1:size(points)[1]
#     if stat[i,1] == true
#         scatter!(ax2, points[i,1], points[i,2], color = :green, markersize = 10)
#     else
#         scatter!(ax2, points[i,1], points[i,2], color = :blue, markersize = 2)
#     end
# end
# f2


inertia = 0.0
p_inpoly = points[stat[:,1],:]
f3 = Figure(resolution = (800,600))
ax3 = Axis(f3[1,1,] , xlabel = "x", ylabel = "y", aspect = DataAspect())
p3 = scatter!(ax3, p_inpoly[:,1], p_inpoly[:,2], color = :red, markersize = 2)
f3
c = 5.0
# dxdy = 1/size(p_inpoly)[1]
dxdy = 0.01*0.01

for i =1:size(p_inpoly)[1]
    x = p_inpoly[i,1]
    y = p_inpoly[i,2]
    r = (y-c)
    inertia += r^2*dxdy
end
println("Calculated: ", inertia)
answer = 1/12*10^4
println("Answer ", answer)
println("error: ", (answer-inertia)/answer*100, " %")
println("result: ", 1/12*10^4)


