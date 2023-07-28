using LinearAlgebra
using GeometryBasics
using Makie, GLMakie
"""
    makepixel(L::Real, t::Real, Lc::Real; n = 10)
L = length of pixel arm
t = thickness
Lc = straight region of pixel (length before arc)
n = number of discretizations for arc
"""
function makepixel(L::Real, t::Real, Lc::Real; n = 10)

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

    return points
end

points = makepixel(150,10,10)

f1 = Figure(resolution = (600, 600))
ax1 = Axis(f1[1,1], aspect = DataAspect(), xlabel = "x", ylabel = "y")
poly!(Point2.(points))
f1