#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
#
# 1D code for plastic additive manufacturing
#  
#
#
# Compton, B.G., Post, B.K., Duty, C.E., Love, L. and Kunc, V., 2017.
# Thermal analysis of additive manufacturing of large-scale thermoplastic polymer composites.
# Additive Manufacturing, 17, pp.77-86.
#
#  Developed by Hayri Sezer, 08/11/2022, Statesboro
#--------------------------------------------------------------------------
#--------------------------------------------------------------------------

using JFVM

# Materials Properties
nlyr = 150;      # number of Layers in the printed part
DelTL= 40.0;       # [s] time to print a layer
k    = 0.17;     # [W/m.K]: Thermal conductivity
Cp   = 1640.0;     # [J/kg.K]: Specific heat capacity
Tg   = 110.0;      # [°C]: Glass transition temperature
rho  = 1140.0;     #  [kg/m3]: Density
eps  = 0.85;     # Emissivity
hconv= 7.0;      # [W/m2.K]: Natural convection coefficient
Tdep = 200.0+273.0;  # Deposition temperature, Tdep [°C]
Tbed = 65.0+273.0;   # Bed temperature, Tbed [°C]	65
Tinf = 18.0+273.0;   # Ambient temperature, T∞ [°C]	18
sigma = 5.670e-8; # W/m2K4
# Geometry
d  = 4.064e-3; # Layer height, d [m]
LF = 0.358;    # Wall height, L [m]
w  = 0.02;     #  Wall thickness, w [m]

ratio = LF/d;
# Define the domain and create a mesh structure
L  = d;  # domain length
nx = 1;  # number of cells in a layer
m  = createMesh1D(nx, L);
# Convective heat transfer coefficient


# Create the boundary condition structure
BC = createBC(m); # all Neumann boundary condition structure
BC.left.a[:] .= 0.0
BC.left.b[:] .= 1.0
BC.left.c[:] .= Tbed  # left boundary
#BC.right.a = 0; BC.right.b=0; BC.right.c=0; # right boundary
x = m.cellcenters.x;
# define the transfer coeffs
D_val = k;
D = createCellVariable(m, D_val);
alfa = createCellVariable(m, rho*Cp);
# define initial values
c_init = Tdep;
c_old = createCellVariable(m, c_init, BC); # initial values
c = c_old; # assign the old value of the cells to the current values

# loop
dt =20; # time step

iglobal     = 0; 
iglobal_old = 0; 
time        = 0; 



for ilyr = 1:nlyr

    # Define the domain and create a mesh structure
    L  = d*ilyr;  # domain length
    Nx = nx*ilyr; # number of cells
    m  = createMesh1D(Nx, L);

    # Convective heat transfer coefficient
    
    
    # Create the boundary condition structure
    BC = createBC(m); # all Neumann boundary condition structure
    BC.left.a[:] .= 0;
    BC.left.b[:] .= 1;
    BC.left.c[:] .= Tbed; # left boundary

    #BC.right.a = 0; BC.right.b=0; BC.right.c=0; % right boundary
    x = m.cellcenters.x;
    # define the transfer coeffs
    D_val = k;
    D     = createCellVariable(m, D_val);
    alfa  = createCellVariable(m, rho*Cp);
    # define initial values
    
    if ilyr>1
        c_init(1:nx*(ilyr-1)) .= c_old.value(2:nx*(ilyr-1)+1);
        c_init(nx*(ilyr-1)+1:nx*ilyr) .= Tdep;
    else
        c_init(nx*(ilyr-1)+1:nx*ilyr) .= Tdep;
    end
    
    c_old  = createCellVariable(m,c_init',BC); # initial values
    c      = c_old; # assign the o
    
    tic
    for t=dt:dt:DelTL
        
        #--- update time and iteration
        iglobal         = iglobal+1;
        time            = time + dt;
        
        
        delx    = m.cellsize.x(end);
        
        T       = c.value;
        Tend    = (T(end)+T(end-1))/2;
        
#--- Top boundary condition
        hradTop = eps*sigma*(Tend + Tdep)*(Tend^2+Tdep^2);
        Flux    = (hradTop + hconv)*(Tdep-Tend)/k;

#         hradTop = eps*sigma*(Tend + Tdep)*(Tend^2+Tdep^2);
#         Flux    = hconv*(Tdep-Tend)/k +eps*sigma*(Tdep.^4 - Tend.^4);


#--- Source term from the sides
        hrad    = eps*sigma*(T + Tinf).*(T.^2+Tinf^2);
#         source = hconv*(Tinf-T)*(2*d)/(w*d);
#         source = (hconv*(Tinf-T)/k + eps*sigma*(Tinf.^4 - T.^4))*(2*w+2*d)/(w*d);
        source  = ((hrad + hconv).*(Tinf-T)*(2*d)/(w*d));
        
        BC.right.a[:] .= 1.0;
        BC.right.b[:] .= 0.0; 
        BC.right.c[:] .= Flux; # right boundary
        
        [M_trans, RHS_trans] = transientTerm(c, dt, alfa);
        Dave = harmonicMean(D);
        
        Mdiff = diffusionTerm(Dave);
        [Mbc, RHSbc] = boundaryCondition(BC);
        SourceCell = createCellVariable(m, source(2:end-1));
        RHS_source = constantSourceTerm(SourceCell);
        
        M = M_trans-Mdiff+Mbc;
        RHS = RHS_trans+RHSbc+RHS_source;
        
        c = solvePDE(m,M, RHS);
        c_old = c;
        
        # save data here 
        for i = 1:ilyr
            LayerTime{i}(iglobal) = time; 
            midInd = 1+round(nx/2)+nx*(i-1);
            LayerTemp{i}(iglobal) = mean(c.value(midInd-floor(nx/2):midInd+floor(nx/2)));
        end
         
        
    end
    
    iglobal_old = iglobal; 
    
    
   
end
toc
# visualization
figure(1);plot(x, c.value(2:Nx+1), '-o');
xlabel('Length [m]'); ylabel('c');
legend('Numerical');
%% Post Processing Here 
figure1 = figure('Color',[1 1 1]);

% Create axes
axes1 = axes('Parent',figure1,...
    'Position',[0.13 0.117547166788915 0.811391941391941 0.837641512456368]);
hold(axes1,'on');

for i = [1 15 30]
%     str = ['Middle point at layer',num2str(i)];
    LayerTime{i} = LayerTime{i}(LayerTime{i}>0);
    LayerTemp{i} = LayerTemp{i}(LayerTemp{i}>0);
    plot(LayerTime{i},LayerTemp{i},'LineWidth',2);
end
hold on
ylabel('Temperature [K]');
xlabel('time [s]');
% box(axes1,'on');
% hold(axes1,'off');
% set(axes1,'FontSize',12,'FontWeight','bold','LineWidth',1,'XGrid','on',...
%     'XMinorGrid','on','YGrid','on','YMinorGrid','on');
% legend1 = legend(axes1,'show');
% set(legend1,...
%     'Position',[0.152625160867209 0.148191829241296 0.369963361721336 0.19221697579015],...
%     'EdgeColor',[1 1 1]);

load('matlab.mat')

plot(a(:,1),a(:,2)+273,'o','LineWidth',2)
%plot(a(:,3),a(:,4)+273,'o','LineWidth',2)
plot(a(:,5),a(:,6)+273,'o','LineWidth',2)
%plot(a(:,7),a(:,8)+273,'o','LineWidth',2)
plot(a(:,9),a(:,10)+273,'o','LineWidth',2)
%plot(a(:,11),a(:,12)+273,'o','LineWidth',2)
hold off
% xlabel('Time (s)')
% ylabel('Temperature (K)')
legend('Middle point at layer 1','Middle point at layer 15', ...
    'Middle point at layer 30','Experimental Middle point at layer 1', ...
    'Experimental Middle point at layer 15', ...
    'Experimental Middle point at layer 30', ...
    'Location','NorthEastOutside')
grid on

