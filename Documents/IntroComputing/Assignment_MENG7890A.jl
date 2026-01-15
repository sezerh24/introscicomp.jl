###########################################################################

using OrdinaryDiffEq, Plots

function ode_system(du, u, p, t)
    du[1] = p[1] * u[1] + p[2] * u[2] - p[3] * u[4]
    du[2] = p[4] * u[3] + p[5] * u[1]
    du[3] = p[2] * u[2] - p[3] * u[4]
    du[4] = p[1] * u[1] + p[4] * u[3] - u[2]
end

u0 = [2.0, 1.0, 3.0, -1.0]
tspan = (0.0, 1.0)
p = [5.0, 8.0, 2.5, 3.0, 1.5]

# Problem definition
prob = ODEProblem(ode_system, u0, tspan, p)

# Solve using Tsit5
sol_tsit5 = solve(prob, Tsit5())

# Solve using RK4
sol_rk4 = solve(prob, RK4(),saveat=0.01) # Saving results at 0.01 for better visualization of comparison

# Plot both solutions
#plot(sol_tsit5.t,sol_tsit5[1, :], label="Tsit5") # For separate results of U1
plot(sol_tsit5, label=["Tsit5 U1" "Tsit5 U2" "Tsit5 U3" "Tsit5 U4"])
plot!(sol_rk4, seriestype=:scatter, markersize=1, label=["RK4 U1" "RK4 U2" "RK4 U3" "RK4 U4"])
xlabel!("Time (s)")
ylabel!("Values")
title!("Solution of ODEs based on 2 solvers")

###########################################################################

using Measurements

# Introducing uncertainty to parameter p3
p_with_uncertainty = [5.0, 8.0, 2.5 ± 0.1, 3.0, 1.5]

# Solve with uncertainty
prob_uncertainty = ODEProblem(ode_system, u0, tspan, p_with_uncertainty)
sol_uncertainty = solve(prob_uncertainty, Tsit5())

Vals_uncertaintyU1 = Measurements.uncertainty.(sol_uncertainty[1,:])
Vals_uncertaintyU2 = Measurements.uncertainty.(sol_uncertainty[2,:])
Vals_uncertaintyU3 = Measurements.uncertainty.(sol_uncertainty[3,:])
Vals_uncertaintyU4 = Measurements.uncertainty.(sol_uncertainty[4,:])

# Plot the results with error bars
plot(sol_uncertainty.t, Measurements.value.(sol_uncertainty[1,:]), yerror=Vals_uncertaintyU1, seriestype=:scatter, label="Uncertainity in U1", xlabel="Time (s)", ylabel="Values", size=(700, 600), linewidth=1, marker=:circle)
plot!(sol_uncertainty.t, Measurements.value.(sol_uncertainty[2,:]), yerror=Vals_uncertaintyU2, seriestype=:scatter, label="Uncertainity in U2", xlabel="Time (s)", ylabel="Values", size=(700, 600), linewidth=1, marker=:circle)
plot!(sol_uncertainty.t, Measurements.value.(sol_uncertainty[3,:]), yerror=Vals_uncertaintyU3, seriestype=:scatter, label="Uncertainity in U3", xlabel="Time (s)", ylabel="Values", size=(700, 600), linewidth=1, marker=:circle)
plot!(sol_uncertainty.t, Measurements.value.(sol_uncertainty[4,:]), yerror=Vals_uncertaintyU4, seriestype=:scatter, label="Uncertainity in U4", xlabel="Time (s)", ylabel="Values", size=(700, 600), linewidth=1, marker=:circle)

# Plot with uncertainty bands
# Error band in U1 only
plot(sol_uncertainty.t, Measurements.value.(sol_uncertainty[1,:]), ribbon=Vals_uncertaintyU1, label="Uncertainity in U1", xlabel="Time (s)", ylabel="Values", size=(700, 600), linewidth=3)
plot!(sol_uncertainty.t, Measurements.value.(sol_uncertainty[2,:]), ribbon=Vals_uncertaintyU2, label="Uncertainity in U2", xlabel="Time (s)", ylabel="Values", size=(700, 600), linewidth=3)
plot!(sol_uncertainty.t, Measurements.value.(sol_uncertainty[3,:]), ribbon=Vals_uncertaintyU3, label="Uncertainity in U3", xlabel="Time (s)", ylabel="Values", size=(700, 600), linewidth=3)
plot!(sol_uncertainty.t, Measurements.value.(sol_uncertainty[4,:]), ribbon=Vals_uncertaintyU4, label="Uncertainity in U4", xlabel="Time (s)", ylabel="Values", size=(700, 600), linewidth=3)

# Error band in all variables
#plot(sol_uncertainty, label="Solution with Uncertainty")

###########################################################################

using SciMLSensitivity

tstops = range(tspan[1], tspan[2], length=1000)  # More points for higher resolution

# Sensitivity analysis using automatic differentiation
sensitivity_prob = ODEForwardSensitivityProblem(ode_system, u0, tspan, p)
sol_sensitivity = solve(sensitivity_prob, Tsit5(),tstops = tstops)
Vals, dp = extract_local_sensitivities(sol_sensitivity)

# Finite Difference Method (FDM) sensitivity
step_size = 0.01
p3_modified = p[3]+ step_size.*p[3]
p_modified = [p[1], p[2] , p3_modified, p[4], p[5]]

prob_fd1 = ODEProblem(ode_system, u0, tspan, p)
sol_fd1 = solve(prob_fd1, Tsit5(),saveat=0.01,tstops = tstops)

prob_fd2 = ODEProblem(ode_system, u0, tspan, p_modified)
sol_fd2 = solve(prob_fd2, Tsit5(),saveat=0.01,tstops = tstops)

# Calculate FDM sensitivity
fdm_sensitivity = (sol_fd2.u .- sol_fd1.u) / (step_size.*p3_modified)
U1_senFDM    = [vec[1] for vec in fdm_sensitivity]
U2_senFDM    = [vec[2] for vec in fdm_sensitivity]
U3_senFDM    = [vec[3] for vec in fdm_sensitivity]
U4_senFDM    = [vec[4] for vec in fdm_sensitivity]

# Plot sensitivities for comparison
plot(sol_sensitivity.t, dp[3]', lw=3, label=["SciML Sensitivity to U1 - Param 3" "SciML Sensitivity to U2 - Param 3" "SciML Sensitivity to U3 - Param 3" "SciML Sensitivity to U4 - Param 3"],size=(700, 600))
plot!(sol_fd2.t,U1_senFDM, seriestype=:scatter, markersize=1, label="FDM Sensitivity to U1 - Param 3", lw = 3)
plot!(sol_fd2.t,U2_senFDM, seriestype=:scatter, markersize=1, label="FDM Sensitivity to U2 - Param 3", lw = 3)
plot!(sol_fd2.t,U3_senFDM, seriestype=:scatter, markersize=1, label="FDM Sensitivity to U3 - Param 3", lw = 3)
plot!(sol_fd2.t,U4_senFDM, seriestype=:scatter, markersize=1, label="FDM Sensitivity to U4 - Param 3", lw = 3)
xlabel!("Time (s)")
ylabel!("Sensitivity")
title!("Sensitivity Analysis based on Parameter 3 (No Uncertainty)")

# Just to give you an idea that at the same time AD generates sensitivities of all parameters on all U1-4  
plot(sol_sensitivity.t, dp[1]',label=["U1-P1" "U2-P1" "U3-P1" "U4-P1"])
plot!(sol_sensitivity.t, dp[2]',label=["U1-P2" "U2-P2" "U3-P2" "U4-P2"])
plot!(sol_sensitivity.t, dp[3]',label=["U1-P3" "U2-P3" "U3-P3" "U4-P3"])
plot!(sol_sensitivity.t, dp[4]',label=["U1-P4" "U2-P4" "U3-P4" "U4-P4"])
plot!(sol_sensitivity.t, dp[5]',label=["U1-P5" "U2-P5" "U3-P5" "U4-P5"])
xlabel!("Time (s)")
ylabel!("Sensitivity")
title!("AD Sensitivity Analysis based on all Parameters")

###########################################################################