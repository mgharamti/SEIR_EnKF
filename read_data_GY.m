function [time, Active, Recovered, Deaths, Vaccinated] = read_data_GY   

time = datetime('01/22/2020'):datetime('06/15/2022');

Confirmed_table = readtable('time_series_covid19_confirmed_guyana.csv');
Recovered_table = readtable('time_series_covid19_recovered_guyana.csv');
Deaths_table    = readtable('time_series_covid19_deaths_guyana.csv');
Vaccine_table   = readtable('Vacc_GY_owid.csv'); % source: ourworldindata.org

% Vaccine_table (1:5, 1:5);


Nr_con = size(Confirmed_table, 1); %number of rows
Nc_con = size(Confirmed_table, 2); %number of columns

Nr_rec = size(Recovered_table, 1); %number of rows
Nc_rec = size(Recovered_table, 2); %number of columns

Nr_deaths = size(Deaths_table, 1); %number of rows
Nc_deaths = size(Deaths_table, 2); %number of columns

Nr_vacc = size(Vaccine_table, 1); %number of rows
Nc_vacc = size(Vaccine_table, 2); %number of columns

Nt = 876;
Nk = 826;

Confirmed  = table2array(Confirmed_table(1:Nt, 2))'; %887r
Recovered  = table2array(Recovered_table(1:Nt, 2))'; Recovered(562:end) = NaN;%887
Deaths     = table2array(Deaths_table(1:Nt, 2))'; %887
Vaccinated = table2array(Vaccine_table(1:Nk, 2 )); %needs to change 887r
Vaccinated = [NaN * ones(Nt-Nk, 1); Vaccinated]';



% Vaccinated = table2array(Vaccine_table(1:Nk, 3 37)); %needs to change 838r


% Confirmed  = table2array(Confirmed_table(Nr_con, 2));
% Recovered  = table2array(Recovered_table(Nr_rec, 2)); %Recovered(328:end) = NaN;
% Deaths     = table2array(Deaths_table(Nr_deaths, 2));
% Vaccinated = table2array(Vaccine_table(Nr_vacc ,2: Nc_vacc)); 
% 
Active = Confirmed - Recovered - Deaths;





% : was commented
% plot(time, Confirmed - Recovered - Deaths, 'b'); hold on 
% plot(time, Recovered,  'r'); grid on 
% plot(time, Deaths,     'g')
% plot(time, Vaccinated, 'm')
% 
% set(gca, 'FontSize', 16)
