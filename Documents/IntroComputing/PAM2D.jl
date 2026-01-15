#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
#
#   Plastic additive manufacturing 2D code
#
#
#
# Owens, J.T., Das, A. and Bortner, M.J., 2022. Accelerating
# heat transfer modeling in material extrusion additive manufacturing:
# From desktop to big area. Additive Manufacturing, 55, p.102853.
#  https://doi.org/10.1016/j.addma.2022.102853
#  Developed by Hayri Sezer, 08/15/2022, Statesboro
#--------------------------------------------------------------------------
#--------------------------------------------------------------------------

# Clear all variables and close figures
#using Printf
#using LessUnitful
using JFVM
using Plots
#@unitfactors m s kg W K J 

# Materials Properties
# nlyr = 4;        # number of Layers in the printed part
DelTL = 39.0      # [s] time to print a layer
k = 0.17          # [W/m.K]: Thermal conductivity
Cp = 1640.0       # [J/kg.K]: Specific heat capacity
Tg = 110.0        # [°C]: Glass transition temperature
rho = 1140.0      # [kg/m3]: Density
eps = 0.87        # Emissivity
hconv = 8.5       # [W/m2.K]: Natural convection coefficient
Tdep = 600 + 273  # Deposition temperature, Tdep [°C]
Tbed = 65 + 273   # Bed temperature, Tbed [°C]
Tinf = 18 + 273   # Ambient temperature, T∞ [°C]
sigma = 5.670e-8  # W/m2K^4
L_vel = 5e-3      # 1 m/s

# Overlapping on y direction 
ylapr = 0.3

# Geometry
d = 4.064e-3      # Layer height, d [m]
LF = 0.358 / 20   # Wall length, L [m]
w = 0.02          # Wall thickness, w [m]
FBD = d           # filament beam diameter [m]
FBDcell = 3       # # number of the cells in the filament beam diameter
ratio = LF / d

# Define the domain and create a mesh structure
Lx = LF           # domain length
Ly = d
dx = FBD / FBDcell
dy = dx

# Calculate the number of cells in each dimension
nx = floor(Int, 1 + Lx / dx)  # number of cells in a layer
ny = floor(Int, 1 + Ly / dy)
#nx = 14
#ny = 4
# Create the mesh structure
m = createMesh2D(nx, ny, Lx, Ly)

# Calculate small time step
dt_small = dx / L_vel

# Convective heat transfer coefficient
# Get the function (placeholder for actual implementation)

# Plastic/Air region
PB = zeros(Int, nx, ny)  # 0 for air, 1 for plastic material

# Create the boundary condition structure
#--------------------------------------------------------------------------
#  X:  Left ---> Right
#  Y:  Bottom ---> Top
#  Z:  Front---> Back
#          2D Computational Domain
#                            y
#                            ^  Ambient (radiation, convection)
#                            |---------|
#          Ambient           |         |
#     (radiation, convection)|         | --> scan direction
#                            |         | Ambient ( radiation, convection)
#                            |         |
#                             ----------> x
#                               Bed
#
#--------------------------------------------------------------------------
BC = createBC(m)  # All Neumann boundary condition structure
BC.bottom.a[:] .= 0
BC.bottom.b[:] .= 1
BC.bottom.c[:] .= Tbed  # The bed boundary
# BC.right.a = 0; BC.right.b = 0; BC.right.c = 0; # Right boundary (commented out)

# Define the transfer coefficients
D_val = k
D = createCellVariable(m, D_val)
alfa = createCellVariable(m, rho * Cp)

# Define initial values
c_init = Tinf
c_old = createCellVariable(m, c_init, BC)  # Initial values
c = c_old  # Assign the old value of the cells to the current values

# Define the square box dimensions
a = FBD
b = FBD

# Get cell center coordinates
x = m.cellcenters.x
y = m.cellcenters.y
#Y, X = meshgrid(y, x)  # Get coordinate of matrix indices
Y, X = [y[i] for i in 1:length(y)], [x[j] for j in 1:length(x)]

function Machine2DTrack(m)
    xx = m.cellcenters.x
    yy = m.cellcenters.y 

    dist = 0.0
    DistL = zeros(length(xx))  # Initialize DistL with zeros
    DistL[1] = 0.0

    for i in 2:length(xx)
        distA = xx[i] - xx[i - 1]
        dist += distA
        DistL[i] = dist
    end

    return xx, yy, DistL
end

# Machine 2D track (placeholder for the actual function)
xx, yy, DistL = Machine2DTrack(m)

# Find the index of the midpoint in y direction
ymid = FBD / 2
dummyy = abs.(yy .- ymid)
midyind = argmin(dummyy)  # Find index of minimum distance to midpoint

# Initialize obstacle array
obst2 = zeros(Int, nx)

# ---- Time and running parameters ----------------------------------------
time = 0.0
Time_loc = 0.0
laser_wait_time = 0.0  # [s] time taken to scan the second layer
dt_wait = dt_small + 0.000001  # During the waiting time, the dt can be large
ii = 1
tplot = 1  # number of iterations to show figures during the simulation
mesh_ii = 1
jj = 0
TimeWait = laser_wait_time
dt = dt_small

# Track the time
mm = 0
current_layer = 1  # shows the current layer

# Loop parameters
tractime = 0
kk = 0
nnM = 0
Layer_Numb = 10
final_t = 10 * (Layer_Numb - 1) * laser_wait_time + 2
Time = zeros(10000)
obst_x = zeros(1000)


while current_layer <= Layer_Numb
    ii += 1
    time += dt
    Time[ii] = time
    c = c_old
    
    if time - sum(tractime) - laser_wait_time * (mm - 1) > laser_wait_time
        dt = dt_small
    end
    
    # This block is used during the machine scanning
    if dt < dt_wait
        Time_loc += dt
        location = Time_loc * L_vel[1]
        NewDist = abs.(DistL .- location)
        ind = argmin(NewDist)  # Find index of minimum distance
        
        #obst_x[ii] = xx[ind]
        # obst_y(ii) = yy(ind) # Uncomment if needed
        
        PBcell = createCellVariable(m, PB)  # Create a cell variable for the air region
        
        obstx = xx .<= xx[ind] .+ a/2 .&& xx .>= xx[ind] .- a/2
        obsty = yy .<= ymid .+ b/2 .&& yy .>= ymid .- b/2
        
        Regionx = findall(obstx)
        Regiony = findall(obsty)
        
        obst2_old = obst2
        obst2 = obst2_old .+ obstx'
        obst2[obst2 .>= 1] .= 1
        condition = mesh_ii > 1
        bool = condition .* ny[(1 - condition) .+ mesh_ii - 1] .+ 1:ny[mesh_ii]
        println(bool)
        for inb in 1:bool
            PB[:, inb] .= obst2
        end
        
        c.value[1 .+ Regionx, 1 .+ Regiony] .= Tdep
        
        # visualizeCells(PBcell)
        
        # pcolor(PB)
        # axis tight
        # axis equal
        # drawnow
    end
    
    # Here the machine will add a new layer; during the new layer addition
    # we can change the scanning directions.
    if location > maximum(DistL)
        mm += 1
        kk[mm] = ii
        dt = dt_wait
        tractime[mm] = Time_loc
        Time_loc = 0
        location = 0
        mesh_ii += 1
        Ly = FBD * mesh_ii  # Additive layer thickness
        ny[mesh_ii] = floor(Int, 1 + Ly / dy)
        m = createMesh2D(nx, ny[mesh_ii], Lx, Ly)
        BC = createBC(m)  # All Neumann boundary condition structure
        BC.bottom.a[:] .= 0
        BC.bottom.b[:] .= 1
        BC.bottom.c[:] .= Tbed  # Bottom boundary
        c = createCellVariable(m, Tinf, BC)
        
        c.value[:, 2:ny[mesh_ii - 1] + 1] .= c_old.value[:, 2:end-1]
        c_old = c
        Dave = harmonicMean(D)
        Mdiff = diffusionTerm(Dave)
        
        xx, yy, DistL = Machine2DTrack(m)
        
        ymid += FBD
        dummyy = abs.(yy .- ymid)
        
        current_layer = mm + 1
        midyind[current_layer] = findfirst(dummyy .== minimum(dummyy))
        
        Y, X = meshgrid(yy, xx)  # Get coordinate of matrix indices
        # obst2(1:Nx, 1:Ny) = 0;  # Uncomment if needed
    end
    
    # Convective heat transfer coefficient
    # Create the boundary condition structure
    # Define the transfer coefficients
    D_val = k
    D = createCellVariable(m, D_val)
    alfa = createCellVariable(m, rho * Cp)
    
    # Material deposition
    # c_dummy = c_old.value(2:end-1, 2:end-1)
    # c_dummy[Regionx, Regiony] .= Tdep
    
    T = c.value
    
    # Initialize the plot outside the loop if you want to update it
    plot_title = "Temperature, Lf & laser temp plot"
    heatmap(X, Y, T[2:end-1, 2:end-1], title=plot_title, color=:jet, c=:auto, aspect_ratio=:equal)
    # Inside the loop, you would typically update the data
    heatmap!(X, Y, T[2:end-1, 2:end-1])  # Updates the same plot with new data
    # Optionally, you can add a colorbar if needed
    colorbar!()
    
    # Boundary condition
    T = c.value
    # Temperatures
    # x---> direction (Left to right)
    TRend = (T[end, :] .+ T[end - 1, :]) ./ 2
    TL1 = (T[1, :] .+ T[2, :]) ./ 2
    hRrad = eps * sigma .* (TRend .+ Tinf) .* (TRend.^2 .+ Tinf^2)
    FR = (hRrad .+ hconv) .* (Tinf .- TRend) ./ k  # Convective and radiative heat flux
    
    hLrad = eps * sigma .* (TL1 .+ Tinf) .* (TL1.^2 .+ Tinf^2)
    FL = -(hLrad .+ hconv) .* (Tinf .- TL1) ./ k  # Convective and radiative heat flux
    
    # Temperatures
    # y---> direction (Top to Bottom)
    TTend = (T[:, end] .+ T[:, end - 1]) ./ 2
    # TB1 = (T[:, 1] .+ T[:, 2]) ./ 2
    
    hTrad = eps * sigma .* (TTend .+ Tinf) .* (TTend.^2 .+ Tinf^2)
    FT = (hTrad .+ hconv) .* (Tinf .- TTend) ./ k  # Convective and radiative heat flux
    
    # BC setup
    BC.right.a[:] .= 1
    BC.right.b[:] .= 0
    BC.right.c[:] .= FR[2:end-1]
    BC.left.a[:] .= 1
    BC.left.b[:] .= 0
    BC.left.c[:] .= FL[2:end-1]
    BC.bottom.a[:] .= 0
    BC.bottom.b[:] .= 1
    BC.bottom.c[:] .= Tbed  # FB(2:end-1); # Bottom boundary
    BC.top.a[:] .= 1
    BC.top.b[:] .= 0
    BC.top.c[:] .= FT[2:end-1]  # Top boundary
    
    # Source term from the sides
    hrad = eps * sigma .* (T .+ Tinf) .* (T.^2 .+ Tinf^2)
    source = (hrad .+ hconv) .* (Tinf .- T) ./ dx
    
    M_trans, RHS_trans = transientTerm(c, dt, alfa)
    Dave = harmonicMean(D)
    
    Mdiff = diffusionTerm(Dave)
    Mbc, RHSbc = boundaryCondition(BC)
    
    SourceCell = createCellVariable(m, source[2:end-1, 2:end-1])
    RHS_source = constantSourceTerm(SourceCell)
    
    M = M_trans - Mdiff + Mbc
    RHS = RHS_trans + RHSbc + RHS_source
    
    c = solvePDE(m, M, RHS)
    c_old = c
    
    # Save data here
    for i in 1:current_layer
        LayerTime[i][ii] = time
        LayerTemp[i][ii] = c.value[floor(Int, nx / 2), midyind[i]]
    end

    # Uncomment for plotting every tplot iterations
    # if ii % tplot == 0
    #     Number_of_iter = ii
    #     jj += 1
    #     T = c.value
    #     
    #     figure(1)
    #     title!("Temperature, Lf & laser temp plot")
    #     
    #     colormap(jet)
    #     contourf(X, Y, T[2:end-1, 2:end-1])
    #     colorbar()
    #     axis equal
    #     axis tight
    #     drawnow()
    #     
    #     println("|   iter   |   time (ms)   |  current layer |    MidPointTemp   |")
    #     println("| -------- | ------------- | ---------------- | ----------------- |")
    #     println("|    $ii    |  $(time * 1e3)     |         $current_layer        |  $(c.value[floor(Int, nx / 2), midyind])        |")
    # end
end



# Visualization
# Create the plot for c.value
plot(x, c.value[2:Nx+1], marker=:o, label="Numerical", xlabel="Length [m]", ylabel="c")

# Post Processing
figure1 = plot(title="Temperature over Time", legend=:topright, background_color=:white)

# Loop through layers to plot temperature data
for i in 1:current_layer
    LayerTime[i] = LayerTime[i][LayerTime[i] .> 0]
    LayerTemp[i] = LayerTemp[i][LayerTemp[i] .> 0]
    
    # Add each layer's data to the plot
    plot!(LayerTime[i], LayerTemp[i], label="Middle point at layer $i", linewidth=2)
end

# Customize the axes
ylabel!("Temperature [K]")
xlabel!("Time [s]")
box!(true)
grid!(true)

# Customize legend
legend!()
