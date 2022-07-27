function [Ol, Y, R, Xa, da] = configure_DA_USA(model, x0, Active, Recovered, Deaths, Vaccinated, my_config_USA)

% Ensemble Size
da.Ne    = my_config_USA.Ne;
da.denom = (model.Nx - 1)*da.Ne;

da.w     = my_config_USA.w;               % Additive inflation
da.clamp = my_config_USA.clamp;           % Clamping state value

da.anamorph = my_config_USA.anamorph;     % State Transformation
da.inflate  = my_config_USA.inflate;      % Multiplicative inflation
da.filter   = my_config_USA.filter;       % Filter kind [EAKF, EnKF, RHF] 

% Initial ensemble perturbation
pert_sig  = [1, 1, 1, 1, 1, 1, 1]; 
pert_type = 'Gaussian';

% What data to assimilate:
% 1- 'ARDV': Active, Recovered, Deaths, Vaccinated
%  - 'AR' : Active, Recovered
% 2- 'DV' : Death, Vaccinated
%  - 'D' : Death

da.data_type = my_config_USA.data_type; 

% Obs error variance
sig_2_active = 1e16;  
sig_2_recovr = 1e14; 
sig_2_deaths = 1e10;  
sig_2_vaccin = 1e15;  

obs_ervar = NaN * ones(1, model.Nx);

obs_ervar(4) = sig_2_active;
obs_ervar(5) = sig_2_recovr;
obs_ervar(6) = sig_2_deaths;
obs_ervar(7) = sig_2_vaccin;

% Observation operators
[~, Ol, Y, R, da] = observer(model.Nx, da, obs_ervar, Active, Recovered, Deaths, Vaccinated);

da.Ny = size(Y, 1);

% Initial Ensemble: 
Xa = zeros(model.Nx, da.Ne);
for ix = 1:model.Nx
    % lognormal: State is positive (Could select different distributions)
    for e = 1:da.Ne
        pert = pert_sig(ix) * randn;        % perturbation size
        if strcmp(pert_type, 'Gaussian')
            Xa(ix, e) = max(da.clamp, x0(ix) + pert); 
        elseif strcmp(pert_type, 'Lognormal')
            Xa(ix, e) = x0(ix) * exp(pert);
        end
    end
end

