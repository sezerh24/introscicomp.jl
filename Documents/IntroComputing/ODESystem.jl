using ModelingToolkit
using DifferentialEquations

## LOTKA VOLTERRA
@parameters a b c d
@variables t x(t) y(t)
D = Differential(t)
eqs = [D(x) ~ a*x - b*x*y,
    D(y) ~ -c*y + d*x*y]


# Define the system
@named sys = ODESystem(eqs)

# Define the initial conditions and parameters
u0 = [x => 1.0,
    y => 1.0]

p = Dict([a => 1.5,
    b => 1.0,
    c => 3.0,
    d => 1.0])

# Define the time span
start = 0; stop = 10; len = 1000 
timesteps = collect(range(start, stop, length = len))

# Simulate the system
prob = ODEProblem(sys, u0,(timesteps[1], timesteps[end]) ,p, saveat = timesteps)
sol = solve(prob)
sol.u

using PhysicsInformedRegression
