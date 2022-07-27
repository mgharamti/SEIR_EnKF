function [model, x0] = initialize_seir_exps_GY(ti, tl, tv, tf, my_config)

% Variable definitions: 
model.Npop = 794045;      % GY population 
model.Nx   = 7;           % size of the state -- how is this defined?

model.dt = 1/24;          % time step

% Timing
model.time1  = datetime(ti, 'Format', 'yyyy-MM-dd') : datetime(tl, 'Format', 'yyyy-MM-dd') - 1;
model.time2  = datetime(tl, 'Format', 'yyyy-MM-dd') : datetime(tv, 'Format', 'yyyy-MM-dd') - 1;
model.time3  = datetime(tv, 'Format', 'yyyy-MM-dd') : datetime(tf, 'Format', 'yyyy-MM-dd');
model.time   = [model.time1, model.time2, model.time3];

model.Nt1 = numel(model.time1);
model.Nt2 = numel(model.time2) + model.Nt1;
model.Nt3 = numel(model.time3) + model.Nt2;
model.Nt  = model.Nt3;
model.Np  = 25;           % no of model integrations (1 day)

% parameters
model.tinc    = 5.6;        % Incubation period [1/gamma] (source: webmed.com)
model.tinf    = 3.8;        % Infection time    [1/delta] (source: CDC)
model.trec    = 14;         % Recovery time     [1/lambda] (source: webmed.com)
model.kappa   = 0.00308;    % Mortality rate   [kappa] e.g., 307.58 per 100,000 pop (source: John Hopkins)
model.tdea    = 7;          % Time until death  [1/rho]

model.mu      = 2.4776e-5;  % natural death rate [US: 8,295/Npop]7.7/1000;% (source: https://worldpopulationreview.com/countries/deaths-per-day)
model.Lambda  = 100;        % new birth and new residents [TODO: check the accuracy of this] 

model.Rp1     = 2.5;        % Basic reproduction number before lockdown
model.Rp2     = 1.0;        % Basic reproduction number after lockdown
model.beta1   = 0.35/model.Npop;   % .45transmission rate before intervention [lead to R > 1; unstable i.e., exponential growth]
model.beta2   = 0.20/model.Npop;   % .40transmission rate during/after intervention [leads to R < 1; stable]

model.alpha1  = 0.0;         % vaccination rate (introduced later in time!)
model.alpha2  = 7e-3;    
model.sigma   = 0.215;       % .175 vacc efficiency (pfizer: 95%, JJ: 70%) take average?!

% Periods for: Vaccination rate 
a1 = 0.0 * ones(1, model.Nt2);
a2 = 0.2 * ones(1, 100);
a3 = 0.4 * ones(1, 200); 
a4 = 0.8 * ones(1, model.Nt - (300+model.Nt2));

model.A = [a1, a2, a3, a4] / 100;

% Periods for: Transmission rate (should related to lockdown/intervention)
b1 = 0.40 * ones(1, 50);        % ~first 50 days --- 03-11-2020
b2 = 0.46 * ones(1, 50);        % approaching first lockdown
b3 = 0.30 * ones(1, 50);        % during lockdown (people start behaving themselves)
b4 = 0.15 * ones(1, 50);        % summer; things are opening up
b5 = 0.25 * ones(1, 50);        % mid summer 2020
b6 = 0.30 * ones(1, 250);       % fall, people getting sick again
b7 = 0.40 * ones(1, 200);       % delta wave
b8 = 0.45 * ones(1, 876-700);   % omicron wave --- 3/2/2022

model.B = [b1, b2, b3, b4, b5, b6, b7, b8] / model.Npop;

model.p = my_config.p;

% state variables
Q0 = 1;     % quarantined (confirmed and infected)
I0 = 1;     % infected (not yet quarantined)
E0 = 1;     % exposed (not yet infected)
R0 = 0;     % recovered
D0 = 0;     % dead
V0 = 0;     % vaccinated
S0 = model.Npop - E0 - I0 - Q0 - R0 - D0;

x0 = [S0, E0, I0, Q0, R0, D0, V0]';

model.varnames = {'Susceptible', 'Exposed', 'Infected', 'Quarantined', ...
                  'Recovered', 'Deaths', 'Vaccinated'};