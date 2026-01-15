using FiniteVolumeMethod, DelaunayTriangulation, ElasticArrays
r = 1.0
#α = 2π;

α = π / 4
β = π/12
points = [(0.0, 0.0), (r, 0.0), (r*cos(β), r*sin(β)), (r*cos(α), r*sin(α))]
bottom_edge = [1, 2]
#arc1 = CircularArc(β, α, 0)
#arc1 = CircularArc((r, 0.0), (r*cos(β), r*sin(β)), (0.0, 0.0);positive = true)
#arc2 = CircularArc((r*cos(β), r*sin(β)), (r*cos(α), r*sin(α)), (0.0, 0.0); positive = true)
edge1 = [2,3]
edge2 = [3,4]
upper_edge = [4, 1]


#arc1 = CircularArc((0.0, r), (r, 0.0), (0.0, 0.0))
#arc2 = CircularArc((r, 0.0), (0.0, r), (0.0, 0.0))
#circle = CircularArc((r, 0.0), (cos(α), sin(α)), (0.0, 0.0))

points = NTuple{2, Float64}[]
#boundary_nodes = [bottom_edge,[arc1],[arc2],upper_edge]
boundary_nodes = [bottom_edge,edge2,edge1, upper_edge]


tri = triangulate(points; boundary_nodes)
A = get_area(tri)
refine!(tri; max_area=1e-3A)
mesh = FVMGeometry(tri)

using CairoMakie
triplot(tri)

befunc  = (x, y, t, u, p) -> oftype(u, 40) # dirichlet constant value 
arc1bc = (x, y, t, u, p) -> oftype(u,10) # flux 
arc2bc  = (x, y, t, u, p) -> zero(u)# Neumann zero flux
uefunc = (x, y, t, u, p) -> oftype(u, 40) # dirichlet constant value

types = (Dirichlet, Dirichlet, Neumann, Dirichlet)
BCs = BoundaryConditions(mesh, (befunc, arc1bc, arc2bc, uefunc), types)

using Bessels


f = (x, y) -> 0.01*y+40
D = (x, y, t, u, p) -> u

initial_condition = [f(x, y) for (x, y) in DelaunayTriangulation.each_point(tri)]
final_time = 10

prob = FVMProblem(mesh, BCs;
    diffusion_function=D,
    #source_function=R,
    final_time,
    initial_condition)
    using OrdinaryDiffEq, LinearSolve
    alg = FBDF(linsolve=UMFPACKFactorization(), autodiff=false)
    sol = solve(prob, alg, saveat=1)

fig = Figure(fontsize=38)
for (i, j) in zip(1:3, (1, 6, 11))
    ax = Axis(fig[1, i], width=600, height=600,
            xlabel="x", ylabel="y",
            title="t = $(sol.t[j])",
            titlealign=:left)
    tricontourf!(ax, tri, sol.u[j], levels=1:0.01:1.4, colormap=:jet)
    tightlimits!(ax)
end
    resize_to_layout!(fig)
    fig