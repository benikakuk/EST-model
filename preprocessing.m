% Pre-processing script for the EST Simulink model. This script is invoked
% before the Simulink model starts running (initFcn callback function).

%% Load the supply and demand data

timeUnit   = 's';

supplyFile = "Team44_supply.csv";
supplyUnit = "kW";

% load the supply data
Supply = loadSupplyData(supplyFile, timeUnit, supplyUnit);

demandFile = "Team44_demand.csv";
demandUnit = "kW";

% load the demand data
Demand = loadDemandData(demandFile, timeUnit, demandUnit);

%% Simulation settings

deltat = 5*unit("min");
stopt  = min([Supply.Timeinfo.End, Demand.Timeinfo.End]);

%% System parameters

% transport from supply
etaTransformer = 0.98;     % Transformer efficiency [-]
Length = 28;               % Cable length [km]
LengthTwo = 0.5;            % Cable length [km]
Rprime = 3e-2;              % Resistance per unit length [Ω/km]
V = 765e3;                  % Line voltage [V]

% injection system
n = 1.4; % Adiabatic index for air
eta_comp_motor = 0.9; % Compressor motor efficiency
eta_isentropic_comp = 0.9; % Isentropic efficiency of compressor
cp_air = 1005; % Specific heat capacity of air [J/kg.K]
cp_water = 4180; % Specific heat capacity of water [J/kg.K]
epsilon_HX = 0.9; % Heat exchanger effectiveness
R_air = 287; % Gas constant for air [J/kg.K]
T_atm = 290; % Ambient temperature [K]
P_atm = 1e5; % Atmospheric pressure [Pa]
T_coolant_in = 333; % Coolant inlet temperature [K]
T_water_max = 453; % Max water temperature for cooling [K]


% storage system
EStorageMax     = 800.*unit("kWh"); % Maximum energy
EStorageMin     = 0.0*unit("kWh"); % Minimum energy
EStorageInitial = 2.0*unit("kWh"); % Initial energy
bStorage        = 1e-8/unit("s");  % Storage dissipation coefficient

% extraction system
aExtraction = 0.15; % Dissipation coefficient
