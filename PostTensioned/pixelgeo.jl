using LinearAlgebra
"""
By Keith JL.
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

    return points, p5, r
end


g1 = makepixel(2000,200,100)
ptx1 = [i[1] for i in g1[1]]
pty1 = [i[2] for i in g1[1]]

# ptx = vcat(ptx1, -ptx1)
# pty = vcat(pty1, pty1)

ptx = ptx1
pty = pty1

using Makie, GLMakie
f1 = Figure(resolution = (800, 600))
ax1 = Axis(f1[1, 1], xlabel = "x", ylabel = "y", aspect = DataAspect())#, aspect = DataAspect(), xgrid = false, ygrid = false)
p1 = scatter!(ax1, ptx,pty, color = :red )
f1
