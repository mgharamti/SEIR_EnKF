function [time, Active, Recovered, Deaths, Vaccinated] = read_data_ETH   

time = datetime('01/01/2020'):datetime('01/03/2021');

Eth_table = readtable('time_series_covid19_no_vacc_ethiopia.csv'); 


Confirmed  = table2array(Eth_table(1:end, 2))';
Recovered  = table2array(Eth_table(1:end, 3))'; %Recovered(328:end) = NaN;
Deaths     = table2array(Eth_table(1:end, 4))';
Vaccinated = table2array(Eth_table(1:end, 6))'; %Vaccinated (1:end,4) = NaN;



Active = Confirmed - Recovered - Deaths;

% plot(time, Confirmed - Recovered - Deaths, 'b'); hold on 
% plot(time, Recovered,  'r'); grid on 
% plot(time, Deaths,     'g')
% plot(time, Vaccinated, 'm')
% set(gca, 'FontSize', 16)
