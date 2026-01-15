using OrdinaryDiffEq
using Trixi

equations = CompressibleEulerEquations2D(1.4)

function initial_condition_pressure_perturbation(x, t, equations::CompressibleEulerEquations2D)
    xs = 1.5 # location of the initial disturbance on the x axis
    w = 1/8 # half width
    p = exp(-log(2) * ((x[1]-xs)^2 + x[2]^2)/w^2) + 1.0
    v1 = 0.0
    v2 = 0.0
    rho = 1.0
  
    return prim2cons(SVector(rho, v1, v2, p), equations)
  end
  initial_condition = initial_condition_pressure_perturbation

  boundary_conditions = boundary_condition_slip_wall

  solver = DGSEM(polydeg=4, surface_flux=flux_lax_friedrichs,
               volume_integral=VolumeIntegralFluxDifferencing(flux_ranocha))

r0 = 0.5 # inner radius
r1 = 5.0 # outer radius
f1(xi)  = SVector( r0 + 0.5 * (r1 - r0) * (xi + 1), 0.0) # right line
f2(xi)  = SVector(-r0 - 0.5 * (r1 - r0) * (xi + 1), 0.0) # left line
f3(eta) = SVector(r0 * cos(0.5 * pi * (eta + 1)), r0 * sin(0.5 * pi * (eta + 1))) # inner circle
f4(eta) = SVector(r1 * cos(0.5 * pi * (eta + 1)), r1 * sin(0.5 * pi * (eta + 1))) # outer circle

cells_per_dimension = (16, 16)
mesh = StructuredMesh(cells_per_dimension, (f1, f2, f3, f4), periodicity=false)

semi = SemidiscretizationHyperbolic(mesh, equations, initial_condition, solver,
                                    boundary_conditions=boundary_conditions)

tspan = (0.0, 3.0)
ode = semidiscretize(semi, tspan)

analysis_interval = 100
analysis_callback = AnalysisCallback(semi, interval=analysis_interval)

alive_callback = AliveCallback(analysis_interval=analysis_interval)

stepsize_callback = StepsizeCallback(cfl=0.9)

callbacks = CallbackSet(analysis_callback,
                        alive_callback,
                        stepsize_callback);

                        sol = solve(ode, CarpenterKennedy2N54(williamson_condition=false),
                        dt=1.0, # solve needs some value here but it will be overwritten by the stepsize_callback
                        save_everystep=false, callback=callbacks);
            
using Plots
plot(sol)

pd = PlotData2D(sol)
plot(pd["p"])
plot!(getmesh(pd))