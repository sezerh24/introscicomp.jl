
using FiniteVolumeMethod, DelaunayTriangulation, ElasticArrays
r = 1.0
α = π/3 - π/12
β = π/3

edge1 = [(0.0,0.0), (r, 0.0)]
arc1  = CircularArc((r, 0.0), (r*cos(α),r*sin(α)), (0.0,0.0))
arc2  = CircularArc((r*cos(α),r*sin(α)), (r*cos(β),r*sin(β)), (0.0,0.0))
edge2 = [(r*cos(β),r*sin(β)), (0.0,0.0)]

points = NTuple{2, Float64}[]

bn = [[edge1], [arc1],[arc2], [edge2]] 


tri = triangulate(points; boundary_nodes)
