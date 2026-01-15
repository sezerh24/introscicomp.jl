using FiniteVolumeMethod, DelaunayTriangulation

a, b, c, d = 0.0, 2.0, 0.0, 2.0
nx, ny = 50, 50
tri = triangulate_rectangle(a,b,c,d,nx,ny, single_boundary = true)
mesh = FVMGeometry(tri)

using CairoMakie
fig, ax, sc = triplot(tri)
fig

bc = (x, y, t, u, p) -> zero(u)
BCs = BoundaryConditions(mesh, bc, Dirichlet)

f = (x, y) -> y ≤ 1.0 ? 50.0 : 0.0
initial_condition = [f(x, y) for (x, y) in DelaunayTriangulation.each_point(tri)]
D = (x, y, t, u, p) -> 1 / 9

final_time = 0.5
prob = FVMProblem(mesh, BCs; diffusion_function=D, initial_condition, final_time)

using OrdinaryDiffEq
sol = solve(prob, Tsit5(), saveat=0.05)

fig = Figure(fontsize=38)
for (i, j) in zip(1:3, (1, 6, 11))
    local ax
    ax = Axis(fig[1, i], width=600, height=600,
        xlabel="x", ylabel="y",
        title="t = $(sol.t[j])",
        titlealign=:left)
    tricontourf!(ax, tri, sol.u[j], levels=0:5:50, colormap=:jet)
    tightlimits!(ax)
end
resize_to_layout!(fig)
fig