function [time, Active, Recovered, Deaths, Vaccinated] = read_data_USA 

time = datetime('01/22/2020'):datetime('06/15/2022');

Confirmed_table = readtable('time_series_covid19_confirmed_global.csv'); % source:https://data.humdata.org/
Recovered_table = readtable('time_series_covid19_recovered_global.csv');
Deaths_table    = readtable('time_series_covid19_deaths_global.csv');
Vaccine_table   = readtable('Vacc_US_owid.csv');                         % source: ourworldindata.org

Nr = size(Confirmed_table, 1);
Nc = size(Confirmed_table, 2); 
R1 = 259;
R2 = 244;

Confirmed  = table2array(Confirmed_table(R1, 5:Nc));
Recovered  = table2array(Recovered_table(R2, 5:Nc)); Recovered(328:end) = NaN;
Deaths     = table2array(Deaths_table(R1, 5:Nc));
Vaccinated = table2array(Vaccine_table(:,37))'; 

Active = Confirmed - Recovered - Deaths;

