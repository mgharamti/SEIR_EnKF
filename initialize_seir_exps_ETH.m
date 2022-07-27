function [model, x0] = initialize_seir_exps_ETH(ti, tl, tv, tf, my_config_ETH)

% Variable definitions: 
model.Npop = 115e6;     % population (Source: World Bank)
model.Nx   = 7;         % size of the state

model.dt = 1/24; % time step

% Timing
model.time1  = datetime(ti, 'Format', 'yyyy-MM-dd') : datetime(tl, 'Format', 'yyyy-MM-dd') - 1;
model.time2  = datetime(tl, 'Format', 'yyyy-MM-dd') : datetime(tv, 'Format', 'yyyy-MM-dd') - 1;
model.time3  = datetime(tv, 'Format', 'yyyy-MM-dd') : datetime(tf, 'Format', 'yyyy-MM-dd');
model.time   = [model.time1, model.time2, model.time3];

model.Nt1 = numel(model.time1);
model.Nt2 = numel(model.time2) + model.Nt1;
model.Nt3 = numel(model.time3) + model.Nt2;
model.Nt  = model.Nt3;
model.Np  = 25;   % no of model integrations (1 day)

% parameters
model.tinc    = 5.6;        % Incubation period [1/gamma] (source: webmed.com)
model.tinf    = 3.8;        % Infection time    [1/delta] (source: CDC)
model.trec    = 14;         % Recovery time     [1/lambda] (source: webmed.com)
model.kappa   = 0.00347;    % Mortality rate   [kappa] e.g., 307.58 per 100,000 pop (source: John Hopkins)
model.tdea    = 7;          % Time until death  [1/rho]

model.mu      = 6.67/100;   % natural death rate [crude death recorded] (source: https://tradingeconomics.com/ethiopia)
model.Lambda  = 2884858;    % new birth and new residents [for 2020, 2.57% ^] (source: macrotrends.net)

model.Rp1     = 2.5;        % Basic reproduction number before lockdown
model.Rp2     = 1.0;        % Basic reproduction number after lockdown
model.beta1   = 0.999/model.Npop;   % 1.45transmission rate before intervention [lead to R > 1; unstable i.e., exponential growth]
model.beta2   = 1.60/model.Npop;    % 1.40transmission rate during/after intervention [leads to R < 1; stable]

model.alpha1  = 0.0;        % vaccination rate (introduced later in time!)
model.alpha2  = 0.0;        % 7e-3
model.sigma   = 0.90;       % vacc efficiency (pfizer: 95%, JJ: 70%m /covishield: .60) 

% Periods for: Vaccination rate 
a1 = 0.0 * ones(1, model.Nt2);
a2 = 0.0 * ones(1, 100);
a3 = 0.0 * ones(1, 200);
a4 = 0.0 * ones(1, model.Nt - (300+model.Nt2));

model.A = [a1, a2, a3, a4] / 100;

% Periods for: Transmission rate (should related to lockdown/intervention)
b1 = 1.31 * ones(1, 90);        % ~first 50 days| Jan - Mar 
b2 = 1.66 * ones(1, 90);        % approaching first lockdown Apr - Jun 
b3 = 1.36 * ones(1, 90);        % during lockdown (people start behaving themselves)Jul-Sep
b4 = 1.10 * ones(1, 90);        % summer; things are opening up Oct-Dec
b5 = 1.15 * ones(1, model.Nt-360); % omicron wave  

model.B = [b1, b2, b3, b4, b5] / model.Npop;

model.p = my_config_ETH.p;  



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