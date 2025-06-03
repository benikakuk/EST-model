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
aSupplyTransport = 0.01; % Dissipation coefficient
etaTransformer = 0.98;     % Transformer efficiency [-]
Length = 28;               % Cable length [km]
LengthTwo = 0.5;            % Cable length [km]
Rprime = 3e-2;              % Resistance per unit length [Ω/km]
V = 765e3;                  % Line voltage [V]

% injection system
aInjection = 0.1; % Dissipation coefficient

% storage system
EStorageMax     = 10.*unit("kWh"); % Maximum energy
EStorageMin     = 0.0*unit("kWh"); % Minimum energy
EStorageInitial = 2.0*unit("kWh"); % Initial energy
bStorage        = 1e-6/unit("s");  % Storage dissipation coefficient

% extraction system
aExtraction = 0.1; % Dissipation coefficient

% transport to demand
aDemandTransport = 0.01; % Dissipation coefficient