function [model, da, obs, diags, state] = DA_exps_TR(my_config)

rng('default') 

% [i] period before/after lockdown, [ii] vaccination, [iii] final time:
ti = '2020-01-22';   %first day of the data 
tl = '2020-03-14'; 
tv = '2021-03-30';
tf = '2022-06-15';

% Initialize Model:
[model, x0] = initialize_seir_exps_TR(ti, tl, tv, tf, my_config);


% Data:
[~, obs.Active, obs.Recovered, obs.Deaths, obs.Vaccinated] = read_data_TR;


% DA Configuration:
[Ol, Y, R, Xa, da] = configure_DA_exps_TR(model, x0, obs.Active, obs.Recovered, obs.Deaths, obs.Vaccinated, my_config);


% Free Run
x = x0;
state.X    = zeros(model.Nx, model.Nt);
diags.RMSE = zeros(da.Ny, model.Nt);

for t = 1:model.Nt

    if model.p == 1
        if t <= model.Nt1
            model.beta = model.beta1; 
        else
            model.beta = model.beta2; 
        end
        if t > model.Nt2 
            model.alpha = model.alpha2;
        else
            model.alpha = model.alpha1;
        end
    else
        model.alpha = model.A(t);
        model.beta  = model.B(t);
    end
    
    x = seir_rk4(model, x);
    
    state.X(:, t) = x;
    
    for o = 1:da.Ny
        diags.RMSE(o, t) = abs(x(Ol(o)) - Y(o, t));
    end
end  

% DA loop
t  = 1;
Xf = Xa;

diags.RMSEf = zeros(da.Ny, model.Nt);
diags.RMSEa = diags.RMSEf;
diags.AESPf = diags.RMSEf;
diags.AESPa = diags.RMSEf;


state.Xprior     = zeros(model.Nx, da.Ne, model.Nt);
Active_ens = zeros(da.Ne, model.Nt);
Suspet_ens = Active_ens;
Recovr_ens = Active_ens;
Deaths_ens = Active_ens;
Vaccin_ens = Active_ens;

while t <= model.Nt

    % Forecast Step:
    if model.p == 1
        if t <= model.Nt1
            model.beta = model.beta1; % need to adjust to reflect Trinidad in initi...
        else
            model.beta = model.beta2; % need to adjust to reflect Trinidad in initi...
        end
        if t > model.Nt2 
            model.alpha = model.alpha2;
        else
            model.alpha = model.alpha1;
        end
    else
        model.alpha = model.A(t);
        model.beta  = model.B(t);
    end

    Z = da.w * mean(Xa, 2);
    for e = 1:da.Ne
        Xf(:, e) = seir_rk4(model, Xa(:, e)) + Z .* randn(model.Nx, 1);
    end
    Xfm  = mean(Xf, 2);
    Xs_f = Xf - Xfm * ones(1, da.Ne);

    
%disp(['Assimilation Cycle: ' num2str(t) ', Time: ' datestr(model.time(t)) ])

    for e = 1:da.Ne
        Xf(:, e) = da.inflate * (Xf(:, e) - Xfm) + Xfm;
    end

    % Analysis Step
    if da.anamorph
        Xa = log(max(da.clamp, Xf)); 
    else
        Xa = Xf;
    end

    for o = 1:da.Ny
        % Find obs increments
        obs_prior      = Xa(Ol(o), :);
        
        obs_prior_mean = mean(obs_prior);
        obs_prior_sd_2 = var(obs_prior);
        
        obs_cen        = obs_prior - obs_prior_mean;

        switch da.filter
            case 'EnKF'
                obs_inc = obs_increment_enkf(obs_prior, Y(o, t), R(o, o));
            case 'EAKF'
                obs_inc = obs_increment_eakf(obs_prior, Y(o, t), R(o, o));
            case 'RHF'
                obs_inc = obs_increment_rhf(obs_prior, Y(o, t), R(o, o));
        end

        % Update state
        for ix = 1:model.Nx
            increment = state_incs(Xa(ix, :), obs_cen, obs_prior_sd_2, obs_inc);
            Xa(ix, :)  = Xa(ix, :) + increment;
        end
    end 

    if da.anamorph
        Xa = exp(Xa);
    else
        Xa(Xa < 0.0) = da.clamp;
    end

    Xam  = mean(Xa, 2);
    Xs_a = Xa - Xam * ones(1, da.Ne); 


    % Diagnostics:
    for o = 1:da.Ny
        diags.RMSEf(o, t) = abs(Xfm(Ol(o)) - Y(o, t));
        diags.RMSEa(o, t) = abs(Xam(Ol(o)) - Y(o, t));
        
        diags.AESPf(o, t) = sqrt(sum(Xs_f(:).^2) / da.denom);
        diags.AESPa(o, t) = sqrt(sum(Xs_a(:).^2) / da.denom);
    end
    state.Xprior(:, :, t)  = Xf;
    Suspet_ens(:, t) = Xf(1, :);
    Active_ens(:, t) = Xf(4, :);
    Recovr_ens(:, t) = Xf(5, :);
    Deaths_ens(:, t) = Xf(6, :);
    Vaccin_ens(:, t) = Xf(7, :);

    % Next Cycle
    t = t + 1;
end


%% Results
bL = [  30, 144, 255 ]/255;
rD = [ 255,  51,  51 ]/255;
gR = [   0, 153,   0 ]/255;
pR = [ 153,  51, 255 ]/255;
oR = [ 255, 153,  51 ]/255;
gY = [ 210, 210, 210 ]/255;

if my_config.results

    figure('pos', [100, 100, 1200, 600])
    
    subplot(221)
    E = plot(model.time, Suspet_ens, 'Color', bL, 'LineWidth', 1); hold on 
    M = plot(model.time, mean(Suspet_ens, 1), 'Color', 'k', 'LineWidth', 2);
    S = plot(model.time, state.X(1, :), 'Color', oR, 'LineWidth', 2);
    set(gca, 'FontSize', 14, 'YGrid', 'on')
    title('Susceptible', 'FontSize', 20)
    legend([E(1), M, S], 'Prior Ensemble', 'Ensemble Mean', 'Model', 'Location', 'East')
    
    subplot(222)
    E = plot(model.time, Active_ens, 'Color', bL, 'LineWidth', 1); hold on 
    M = plot(model.time, mean(Active_ens, 1), 'Color', 'k', 'LineWidth', 2);
    S = plot(model.time, state.X(4, :), 'Color', oR, 'LineWidth', 2);
    set(gca, 'FontSize', 14, 'YGrid', 'on')
    title('Quarantined', 'FontSize', 20)
    legend([E(1), M, S], 'Prior Ensemble', 'Ensemble Mean', 'Model', 'Location', 'NorthEast')
    
    subplot(223)
    E = plot(model.time, Deaths_ens, 'Color', bL, 'LineWidth', 1); hold on 
    M = plot(model.time, mean(Deaths_ens, 1), 'Color', 'k', 'LineWidth',2);
    D = plot(model.time, obs.Deaths, '.r');
    S = plot(model.time, state.X(6, :), 'Color', oR, 'LineWidth', 2);
    set(gca, 'FontSize', 14, 'YGrid', 'on')
    title('Deaths', 'FontSize', 20)
    legend([E(1), M, D, S], 'Prior Ensemble', 'Ensemble Mean', 'Data', 'Model', 'Location', 'NorthWest')
    
    subplot(224)
    E = plot(model.time, Vaccin_ens, 'Color', bL, 'LineWidth', 1); hold on 
    M = plot(model.time, mean(Vaccin_ens, 1), 'Color', 'k', 'LineWidth', 2);
    D = plot(model.time, obs.Vaccinated, '.r');
    S = plot(model.time, state.X(7, :), 'Color', oR, 'LineWidth', 2);
    set(gca, 'FontSize', 14, 'YGrid', 'on')
    title('Fully Vaccinated', 'FontSize', 20)
    legend([E(1), M, D, S], 'Prior Ensemble', 'Ensemble Mean', 'Data', 'Model', 'Location', 'SouthEast')
    
    
    % RMSE 
    for o = 1:da.Ny
        figure
        plot(model.time, diags.RMSE(o, :), 'Color', 'k', 'LineWidth', 2); hold on 
        plot(model.time, diags.RMSEf(o, :), 'Color', bL, 'LineWidth', 2); 
        plot(model.time, diags.RMSEa(o, :), 'Color', rD, 'LineWidth', 2);
        set(gca, 'FontSize', 14, 'YGrid', 'on')
        ylabel('Skill', 'FontSize', 18)
        title(model.varnames(da.vars(o)), 'FontSize', 20)
        L = legend( sprintf('Model: %.3f', nanmean(diags.RMSE(o, :))/1e5), ...
                    sprintf('Prior: %.3f', nanmean(diags.RMSEf(o, :))/1e5), ...
                    sprintf('Posterior: %.3f', nanmean(diags.RMSEa(o, :))/1e5));
        title(L, 'Per 100,000 People')
    end
end