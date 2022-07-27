function [time, Active, Recovered, Deaths, Vaccinated] = read_data_GY   

time = datetime('01/22/2020'):datetime('06/15/2022');

Confirmed_table = readtable('time_series_covid19_confirmed_guyana.csv');% extracted from global data https://data.humdata.org/
Recovered_table = readtable('time_series_covid19_recovered_guyana.csv');
Deaths_table    = readtable('time_series_covid19_deaths_guyana.csv');
Vaccine_table   = readtable('Vacc_GY_owid.csv'); % source: ourworldindata.org


Nt = 876;
Nk = 826;

Confirmed  = table2array(Confirmed_table(1:Nt, 2))'; 
Recovered  = table2array(Recovered_table(1:Nt, 2))'; Recovered(562:end) = NaN;
Deaths     = table2array(Deaths_table(1:Nt, 2))';    
Vaccinated = table2array(Vaccine_table(1:Nk, 2 ));   
Vaccinated = [NaN * ones(Nt-Nk, 1); Vaccinated]';
 
Active = Confirmed - Recovered - Deaths;


% : was commented
% plot(time, Confirmed - Recovered - Deaths, 'b'); hold on 
% plot(time, Recovered,  'r'); grid on 
% plot(time, Deaths,     'g')
% plot(time, Vaccinated, 'm')
% 
% set(gca, 'FontSize', 16)
