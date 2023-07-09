using LinearAlgebra
"""
By Keith JL.
    makepixel(L::Real, t::Real, Lc::Real; n = 10)
L = length of pixel arm
t = thickness
Lc = straight region of pixel (length before arc)
n = number of discretizations for arc
"""
function makepixel(L::Real, t::Real, Lc::Real; n = 100)

    #constants
    θ = pi/6
    ϕ = pi/3
    psirange = range(0, ϕ, n)

    #origin
    p1 = [0., 0.]

    # first set
    p2 = p1 .+ [0., -L]
    p2′ = p1 .+ L .* [cos(θ), sin(θ)]

    #second set
    p3 = p2 .+ [t, 0.]
    p3′ = p2′ + t .* [cos(ϕ), -sin(ϕ)]

    #third set
    p4 = p3 .+ [0., Lc]
    p4′ = p3′ .+ Lc .* [-cos(θ), -sin(θ)]

    #arc
    v4 = p4′ .- p4

    #radius
    r = norm(v4) / cos(ϕ) / 2

    #arc center
    p5 = p4 .+ [r, 0.] 

    arcs = [p5 .+ r .* [-cos(ang), sin(ang)] for ang in psirange]

    points = [p1, p2, p3, p4, arcs..., p4′, p3′, p2′]

    return points, p5, r
end


g1 = makepixel(150,30,20)
ptx1 = [i[1] for i in g1[1]]
pty1 = [i[2] for i in g1[1]]
#remove first point (0.0)
ptx1 = ptx1[2:end]
pty1 = pty1[2:end]
# ptx = vcat(ptx1, -ptx1)
# pty = vcat(pty1, pty1)

ptx = ptx1
pty = pty1

using Makie, GLMakie
f1 = Figure(resolution = (800, 600))
ax1 = Axis(f1[1, 1], xlabel = "x", ylabel = "y", aspect = DataAspect())#, aspect = DataAspect(), xgrid = false, ygrid = false)
p1 = scatter!(ax1, ptx,pty, color = :red )
f1

using PolygonInbounds
nodes = [ptx pty]
x = 0.:100.:2000.
y = -2000.:100.:2000.
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

f2 = Figure(resolution = (800, 600))
ax2 = Axis(f2[1, 1], xlabel = "x", ylabel = "y", aspect = DataAspect())#, aspect = DataAspect(), xgrid = false, ygrid = false)
p2 = scatter!(ax2, ptx,pty, color = :red )
for i = 1:size(points)[1]
    if stat[i,1] == true
        scatter!(ax2, points[i,1], points[i,2], color = :green, markersize = 2)
    else
        scatter!(ax2, points[i,1], points[i,2], color = :blue, markersize = 2)
    end
end
f2

newpoints1 = Matrix{Float64}(undef, size(nodes)[1], 2)
# draw a full pixelframe section
for i = 1:size(nodes)[1]
    x = nodes[i,1]
    y = nodes[i,2]
    r = sqrt(x^2 + y^2)
    θ = atand(y/x)
    # if θ < 0
    #     θ = -θ
    # end
    newθ = θ + 120.0
    newx = r*cosd(newθ)
    newy = r*sind(newθ)
    newpoints1[i,:] = [newx, newy]
end

newpoints2 = Matrix{Float64}(undef, size(nodes)[1], 2)
# draw a full pixelframe section
for i = 1:size(nodes)[1]
    x = nodes[i,1]
    y = nodes[i,2]
    r = sqrt(x^2 + y^2)
    θ = atand(y/x)
    # if θ < 0
    #     θ = -θ
    # end
    newθ = θ + 240.0
    newx = r*cosd(newθ)
    newy = r*sind(newθ)
    newpoints2[i,:] = [newx, newy]
end

f4 = Figure(resolution = (800, 800))
ax4 = Axis(f4[1, 1], xlabel = "x", ylabel = "y", aspect = DataAspect())#, aspect = DataAspect(), xgrid = false, ygrid = false)
scatter!(ax4, newpoints1[:,1],newpoints1[:,2], color = :red )
scatter!(ax4, nodes[:,1],nodes[:,2], color = :blue )
scatter!(ax4, newpoints2[:,1],newpoints2[:,2], color = :green )
newnodes = vcat(nodes, newpoints1, newpoints2)
origin = Matrix{Float64}(undef, 1, 2)
origin[1,:] = [0,0]
# newnodes = vcat(origin,nodes)
f4