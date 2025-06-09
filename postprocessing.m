% Post-processing script for the EST Simulink model. This script is invoked
% after the Simulink model is finished running (stopFcn callback function).

close all;
figure;

%% Supply and demand
subplot(3,2,1);
plot(tout/unit("day"), PSupply/unit("W"));
hold on;
plot(tout/unit("day"), -PDemand/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Supply and demand');
xlabel('Time [day]');
ylabel('Power [W]');
legend("Supply","Demand");

%% Stored energy
subplot(3,2,2);
plot(tout/unit("day"), EStorage/unit("J"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Storage');
xlabel('Time [day]');
ylabel('Energy [J]');

%% Energy losses
subplot(3,2,3);
plot(tout/unit("day"), D/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Losses');
xlabel('Time [day]');
ylabel('Dissipation rate [W]');

%% Load balancing
subplot(3,2,4);
plot(tout/unit("day"), PSell/unit("W"));
hold on;
plot(tout/unit("day"), -PBuy/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Load balancing');
xlabel('Time [day]');
ylabel('Power [W]');
legend("Sell","Buy");

%% Pie charts

% integrate the power signals in time
EfromSupplyTransport = trapz(tout, PfromSupplyTransport);
EtoDemandTransport   = trapz(tout, PtoDemandTransport);
ESell                = trapz(tout, PSell);
EBuy                 = trapz(tout, PBuy);
EtoInjection         = trapz(tout, PtoInjection);
EfromExtraction      = trapz(tout, PfromExtraction);
EStorageDissipation  = trapz(tout, DStorage);
EDirect              = EfromSupplyTransport - ESell - EtoInjection;
ESurplus             = EtoInjection-EfromExtraction-EStorageDissipation;

figure;
tiles = tiledlayout(1,2);

ax = nexttile;
pie(ax, [EDirect, EtoInjection, ESell]/EfromSupplyTransport);
lgd = legend({"Direct to demand", "To storage", "Sold"});
lgd.Layout.Tile = "south";
title(sprintf("Received energy %3.2e [J]", EfromSupplyTransport/unit('J')));

ax = nexttile;
pie(ax, [EDirect, EfromExtraction, EBuy]/EtoDemandTransport);
lgd = legend({"Direct from supply", "From storage", "Bought"});
lgd.Layout.Tile = "south";
title(sprintf("Delivered energy %3.2e [J]", EtoDemandTransport/unit('J')));

%% ============== DISPLAY RESULTS Expansion ===========================================================================
fprintf('=== SYSTEM OUTPUTS ===\n');
%fprintf('Total Power Delivered (PtoExtraction): %.2f kW\n', PtoExtraction);
%fprintf('Power Deficit (DExtraction): %.2f kW\n', DExtraction);
%fprintf('Air Mass Flow Rate: %.3f kg/s\n', m_dot_air);
%fprintf('Total Cooling Water Flow: %.3f kg/s\n\n', m_dot_water_total);

%% ============== TABULATE STAGE-WISE OUTPUTS ===================
Stage = (1:3)';  % Adjust if different number of stages
T_after_reheat = T_TES';
T_after_expansion = T_out';
P_out_bar = P_out' / 1e5;          % Convert Pa to bar
W_exp_kJ = W_exp' / 1000;          % Convert to kJ/kg
Ex_thermal_kJ = Ex_thermal' / 1000;
Water_Flow = m_dot_water';

T = table(Stage, T_after_reheat, T_after_expansion, P_out_bar, ...
          W_exp_kJ, Ex_thermal_kJ, Water_Flow);
disp(T);

%% ============== PLOTS: TEMPERATURE & PRESSURE =================
figure;
plot(Stage, T_after_reheat, 'ro-', Stage, T_after_expansion, 'bo-', 'LineWidth', 2);
xlabel('Expansion Stage'); ylabel('Temperature [K]');
legend('After Reheat', 'After Expansion');
title('Temperature after Reheat and Expansion');
grid on;

figure;
plot(Stage, P_in / 1e5, 'ro-', Stage, P_out / 1e5, 'bo-', 'LineWidth', 2);
xlabel('Expansion Stage'); ylabel('Pressure [bar]');
legend('Before Expansion', 'After Expansion');
title('Pressure per Stage');
grid on;
%% ============== PLOTS: EFFICIENCYS AND COMPONENTS ==============

%finding the efficiencies 

efficiency_supply_transport = (PfromSupplyTransport / PtoSupplyTransport) * 100;
efficiency_injection = (PfromInjection / PtoInjection) * 100;
efficiency_storage = (EStorage / PtoStorage) * 100;
efficiency_extraction = (PtoExtraction / PfromExtraction) * 100;
efficiency_demand_transport = (PtoDemandTransport / PfromDemandTransport) * 100;

efficiency_components = [efficiency_supply_transport, efficiency_injection, efficiency_storage, ...
    efficiency_extraction, efficiency_demand_transport];
components = {'Supply', 'Injection', 'Storage', 'Extraction', 'Demand'};

%plotting them

subplot(3,2,5);
figure;
plot(components, efficiency_components, 'LineWidth', 2);
set(gca, 'XTick', 1:5, 'XTickLabel', components);
xlabel('Component'); ylabel('Efficiency [%]');
legend('Efficiency');
title('Efficiency of each component');
grid on;
