using PolygonInbounds
using Makie, GLMakie

#Section definition
# nodes = [ptx pty] is a matrix of the outline of the section centers at (0,0).
# For example a 150 x 200 rectangular section would be:
nodes = [-75.0 -100.0; 
          75.0 -100.0;
          75.0 100.0; 
          -75.0 100.0 ]

#or with a "makepixel" function.

p1 = makepixel(150,30,20)[1]
ptx = [i[1] for i in p1[2:end]]
pty = [i[2] for i in p1[2:end]]
p_right = [ptx pty]
p_left = Matrix{Float64}(undef, size(p_right)[1], 2)
p_top = Matrix{Float64}(undef, size(p_right)[1], 2)

for i = 1:size(p_right)[1]
    x = p_right[i,1]
    y = p_right[i,2]
    r = sqrt(x^2 + y^2)
    θ = atand(y/x)

    newθ = θ + 120.0
    newx = r*cosd(newθ)
    newy = r*sind(newθ)
    p_top[i,:] = [newx, newy]

    newθ = θ + 240.0
    newx = r*cosd(newθ)
    newy = r*sind(newθ)
    p_left[i,:] = [newx, newy]
end

nodes = [p_right; p_top; p_left]

#check the section
s1 = Figure(resolution = (800,600))
ax1 = Axis(s1[1,1], xlabel = "x", ylabel = "y", 
        aspect = DataAspect(),
        limits = (-205,205,-200,150))

sec1 = scatter!(ax1, nodes[:,1], nodes[:,2], color = :red)
s1
# nodes = newnodes
dx = 0.05
dy = 0.05
x = -205.0:dx:205.0
y = -200.0:dy:150.0
#create a matrix of grid points.
points = Matrix{Float64}(undef, size(x)[1]*size(y)[1], 2)
for i =1:size(x)[1]
    for j = 1:size(y)[1]
        points[(i-1)*size(y)[1]+j,:] = [x[i], y[j]]
    end
end
edges = Matrix{Int64}(undef, size(nodes)[1], 2)
for i = 1:(size(nodes)[1]-1)
        edges[i,:] =  [i, i+1]
end
edges[size(nodes)[1],:] = [size(nodes)[1], 1]
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

p_inpoly = points[stat[:,1],:]
area =dx*dy*size(p_inpoly)[1]

chk = Vector{Bool}(undef, size(p_inpoly)[1])
c_pos = 80.0
for i =1:size(p_inpoly)[1]
    x = p_inpoly[i,1]
    y = p_inpoly[i,2]
    if y>c_pos
        chk[i] = true
    else
        chk[i] = false
    end
end

com_pts = p_inpoly[chk,:]

f3 = Figure(resolution = (800,600))
ax3 = Axis(f3[1,1,] , xlabel = "x", ylabel = "y", aspect = DataAspect())
p3 = scatter!(ax3, p_inpoly[:,1], p_inpoly[:,2], color = :red, markersize = 2)
f3


p4 = scatter!(ax3, com_pts[:,1], com_pts[:,2], color = :green, markersize = 1)
f3


pts = p_inpoly
pts = com_pts
area = size(pts)[1]*dx*dy
cgx = 0.0
cgy = 0.0
inertia = 0.0
c = 0.0
# dxdy = 1/size(p_inpoly)[1]
dxdy = dx*dy
for i =1:size(pts)[1]
    x = pts[i,1]
    y = pts[i,2]
    r = (y-c)
    inertia += r^2*dxdy
    cgx += x*dxdy
    cgy += y*dxdy
end
cg = (cgx/area, cgy/area)
p4 = scatter!(ax3, cg[1], cg[2], color = :blue, markersize = 10)
f3


Area = size(p_inpoly)[1]*dxdy
inertia
answer = 1.1867e8
println("Calculated: ", inertia)
# answer = 1/12*10^4

println("Answer ", answer)
println("error: ", (answer-inertia)/answer*100, " %")
# println("result: ", 1/12*10^4)


# ####################################


#given area, get depths
target_a = 1500.0
tol = 0.01
for depth_ratio = 0:0.01:1
    #more efficient by adding more points?
    #if the points are sorted, we could continue?, but with each depth.

    chk = Vector{Bool}(undef, size(p_inpoly)[1])
    @show c_pos = 100-depth_ratio*200.0
    for i =1:size(p_inpoly)[1]
        #could stop right away when the points violate the depth (move in sorted list)
        x = p_inpoly[i,1]
        y = p_inpoly[i,2]
        if y>c_pos
            chk[i] = true
        else
            chk[i] = false
        end
    end
    com_pts = p_inpoly[chk,:]
    @show area =dx*dy*size(com_pts)[1]
    @show diff = abs(area-target_a)/target_a
    if diff < tol 
        println("the depth is at y = ", depth_ratio*200.0)
        break
    end
end

