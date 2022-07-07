function [time, Active, Recovered, Deaths, Vaccinated] = read_data_TR   

time = datetime('01/22/2020'):datetime('06/15/2022');

Confirmed_table = readtable('time_series_covid19_confirmed_global.csv');
Recovered_table = readtable('time_series_covid19_recovered_global.csv');
Deaths_table    = readtable('time_series_covid19_deaths_global.csv');
Vaccine_table   = readtable('Vacc_TR_owid.csv'); % source: ourworldindata.org

Nr = size(Confirmed_table, 1);
Nc = size(Confirmed_table, 2); 
R1 = 256;
R2 = 241;

Nt = 876;
Nk = 824;

Confirmed  = table2array(Confirmed_table(R1, 5:Nc));
Recovered  = table2array(Recovered_table(R2, 5:Nc)); Recovered(328:end) = NaN;
Deaths     = table2array(Deaths_table(R1, 5:Nc));
Vaccinated = table2array(Vaccine_table(1:Nk, 37 )); %needs to change 887r
Vaccinated = [NaN * ones(Nt-Nk, 1); Vaccinated]';

%Vaccinated = table2array(Vaccine_table(:,37))'; %needs to change
%nt - 824
Active = Confirmed - Recovered - Deaths;

% plot(time, Confirmed - Recovered - Deaths, 'b'); hold on 
% plot(time, Recovered,  'r'); grid on 
% plot(time, Deaths,     'g')
% plot(time, Vaccinated, 'm')
% 
% set(gca, 'FontSize', 16)
