using DelaunayTriangulation, FiniteVolumeMethod, CairoMakie
A, B, C, D, E, F, G = (0.0, 0.0),
(0.06, 0.0),
(0.06, 0.03),
(0.05, 0.03),
(0.03, 0.05),
(0.03, 0.06),
(0.0, 0.06)
bn1 = [G, A, B]
bn2 = [B, C]
bn3 = [C, D, E, F]
bn4 = [F, G]
bn = [bn1, bn2, bn3, bn4]
boundary_nodes, points = convert_boundary_points_to_indices(bn)
tri = triangulate(points; boundary_nodes)
refine!(tri; max_area=1e-4get_area(tri))
triplot(tri)

mesh = FVMGeometry(tri)

k = 3.0
h = 20.0
T∞ = 20.0
bc1 = (x, y, t, T, p) -> zero(T) # ∇T⋅n=0
bc2 = (x, y, t, T, p) -> oftype(T, 40.0) # T=40
bc3 = (x, y, t, T, p) -> -p.h * (p.T∞- T) / p.k # k∇T⋅n=h(T∞-T). The minus is since q = -∇T
bc4 = (x, y, t, T, p) -> oftype(T, 70.0) # T=70
parameters = (nothing, nothing, (h=h, T∞=T∞, k=k), nothing)
BCs = BoundaryConditions(mesh, (bc1, bc2, bc3, bc4),
    (Neumann, Dirichlet, Neumann, Dirichlet);
    parameters)

diffusion_function = (x, y, t, T, p) -> one(T)
f = (x, y) -> 500y + 40
initial_condition = [f(x, y) for (x, y) in DelaunayTriangulation.each_point(tri)]
final_time = Inf
prob = FVMProblem(mesh, BCs;
    diffusion_function,
    initial_condition,
    final_time)

steady_prob = SteadyFVMProblem(prob)

using OrdinaryDiffEq, SteadyStateDiffEq
sol = solve(steady_prob, DynamicSS(Rosenbrock23()))

fig, ax, sc = tricontourf(tri, sol.u, levels=40:70, axis=(xlabel="x", ylabel="y"))
fig