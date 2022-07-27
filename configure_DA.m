function [Ol, Y, R, Xa, da] = configure_DA(model, x0, Active, Recovered, Deaths, Vaccinated)

Ensemble Size
da.Ne    = 20;
da.denom = (model.Nx - 1)*da.Ne;

da.w     = 0.0001;      % Additive inflation
da.clamp = 1.e-10;      % Clamping state value

da.anamorph = true;     % State Transformation
da.inflate  = 1.02;     % Multiplicative inflation
da.filter   = 'EAKF';   % Filter kind [EAKF, EnKF, RHF] 

Initial ensemble perturbation
pert_sig  = [1, 1, 1, 1, 1, 1, 1]; 
pert_type = 'Gaussian';

What data to assimilate:
1- 'ARDV': Active, Recovered, Deaths, Vaccinated
 - 'AR' : Active, Recovered
2- 'DV' : Death, Vaccinated
 - 'D' : Death

da.data_type = 'DV'; 

Obs error variance for different data
May need to change these
sig_2_active = 1e65;  %e16
sig_2_recovr = 1e34;  %e14
sig_2_deaths = 1e20;  %e10
sig_2_vaccin = 1e15;  %e15

obs_ervar = NaN * ones(1, model.Nx);

obs_ervar(4) = sig_2_active;
obs_ervar(5) = sig_2_recovr;
obs_ervar(6) = sig_2_deaths;
obs_ervar(7) = sig_2_vaccin;

Observation operators
[~, Ol, Y, R, da] = observer(model.Nx, da, obs_ervar, Active, Recovered, Deaths, Vaccinated);

da.Ny = size(Y, 1);

Initial Ensemble: 
Xa = zeros(model.Nx, da.Ne);
for ix = 1:model.Nx
    lognormal: State is positive (Could select different distributions)
    for e = 1:da.Ne
        pert = pert_sig(ix) * randn;        % perturbation size
        if strcmp(pert_type, 'Gaussian')
            Xa(ix, e) = max(da.clamp, x0(ix) + pert); 
        elseif strcmp(pert_type, 'Lognormal')
            Xa(ix, e) = x0(ix) * exp(pert);
        end
    end
end

