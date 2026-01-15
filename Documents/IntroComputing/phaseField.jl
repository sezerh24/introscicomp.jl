using JFVM
Nx = 400
Ny = 100
m = createMesh2D(Nx, Ny, Nx, Ny)
BCp = createBC(m)
p_init = zeros(Nx,Ny)
p_init[1:10, 1:Ny] .= 1.0 # initial value of the variable
p_old = createCellVariable(m, p_init, BCp)

BCT    = createBC(m)
T_init = zeros(Nx,Ny)
T_old  = createCellVariable(m, T_init, BCT)


K = 1; # latent heat 
ϵ = 0.01; # interface thickness
τ = 0.003; #time constant a = 0.01
γ = 10; 
α = 0.9;


Dp_val = ϵ^2 # value of the diffusion coefficient
Dp_cell = createCellVariable(m, Dp_val) # assigned to cells
# Harmonic average
Dp_face = harmonicMean(Dp_cell)

DT_val = 1 # value of the diffusion coefficient
DT_cell = createCellVariable(m, DT_val) # assigned to cells
# Harmonic average
DT_face = harmonicMean(DT_cell)

DTp_val = 1 # value of the diffusion coefficient
DTp_cell = createCellVariable(m, DTp_val) # assigned to cells
# Harmonic average
DTp_face = harmonicMean(DTp_cell)


N_steps = 20 # number of time steps
dt= sqrt(Lx^2/D_val)/N_steps # time step
M_diff = diffusionTerm(D_face) # matrix of coefficient for diffusion term
(M_bc, RHS_bc)=boundaryConditionTerm(BC) # matrix of coefficient and RHS for the BC
for i =1:5
    (M_t, RHS_t)=transientTerm(c_old, dt, 1.0)
    M=M_t-M_diff+M_bc # add all the [sparse] matrices of coefficient
    RHS=RHS_bc+RHS_t # add all the RHS's together
    c_old = solveLinearPDE(m, M, RHS) # solve the PDE
end
visualizeCells(c_old)