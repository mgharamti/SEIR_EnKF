clc
close all

% NOTE: Compile 'my_config_USA' in 'compare_runs_USA' before running this code

rng('default') 

% period before/after lockdown
ti = '2020-01-22';   
tl = '2020-04-20'; 
tv = '2020-12-14';
tf = '2022-06-15';

% Time definition:
[model, x] = initialize_seir_exps_USA(ti, tl, tv, tf, my_config_USA);

% Data:
[~, Active, Recovered, Deaths, Vaccinated] = read_data_USA;


% Model run: 
X = zeros(model.Nx, model.Nt);
for k = 1:model.Nt

    if model.p == 1
        if k <= model.Nt1             % before vacc
            model.beta = model.beta1; % before lockdown
        else
            model.beta = model.beta2; 
        end

        if k > model.Nt2              % after vacc
            model.alpha = model.alpha2;
        else
            model.alpha = model.alpha1;
        end
    else       
        model.alpha = model.A(k);
        model.beta = model.B(k);
    end

    x = seir_rk4(model, x);
    
    X(:, k) = x;
end   

%% 
bL = [  30, 144, 255 ]/255;
rD = [ 255,  51,  51 ]/255;
gR = [   0, 153,   0 ]/255;
pR = [ 153,  51, 255 ]/255;
oR = [ 255, 153,  51 ]/255;

figure('pos', [100, 100, 1200, 600])

% Note: These subpots represent unreliable Vaccination and Recovered Data.

% subplot(221)
% plot(model.time, X(4, :), 'Color', bL, 'LineWidth', 2); hold on 
% plot(model.time, Active, '.k')
% plot(datetime(tl), 0, 'o', 'Color', '#DC143C', 'MarkerFaceColor', '#DC143C', 'MarkerSize', 12)
% plot(datetime(tv), 0, 'o', 'Color', bL, 'MarkerFaceColor', bL, 'MarkerSize', 12)
% set(gca, 'FontSize', 14, 'YGrid', 'on')
% title('Active Cases', 'FontSize', 20)
% legend('Model', 'Data', 'First Lockdown', 'Vaccination', 'Location', 'NorthEast')

% subplot(222)
% plot(model.time, X(5, :), 'Color', bL, 'LineWidth', 2); hold on 
% plot(model.time, Recovered, '.k')my_config
% plot(datetime(tl), 0, 'o', 'Color','#DC143C', 'MarkerFaceColor','#DC143C', 'MarkerSize', 12)
% plot(datetime(tv), 0, 'o', 'Color', bL, 'MarkerFaceColor', bL, 'MarkerSize', 12)
% set(gca, 'FontSize', 14, 'YGrid', 'on')
% title('Recovered Cases', 'FontSize', 20)
% legend('Model', 'Data', 'First Lockdown', 'Vaccination', 'Location', 'East')

subplot(221)
plot(model.time, X(6, :), 'Color', '#008B00', 'LineWidth', 2); hold on 
plot(model.time, Deaths, '.k')
plot(datetime(tl), 0, 'o', 'Color', '#DC143C', 'MarkerFaceColor', '#DC143C', 'MarkerSize', 12)
plot(datetime(tv), 0, 'o', 'Color', bL, 'MarkerFaceColor', bL, 'MarkerSize', 12)
set(gca, 'FontSize', 14, 'YGrid', 'on')
title('Deaths', 'FontSize', 20)
legend('Model', 'Data', 'First Lockdown', 'Vaccination', 'Location', 'NorthWest')

subplot(222)
plot(model.time, X(7, :), 'Color', '#008B00', 'LineWidth', 2); hold on 
plot(model.time, Vaccinated, '.k')
plot(datetime(tl), 0, 'o', 'Color', '#DC143C', 'MarkerFaceColor', '#DC143C', 'MarkerSize', 12)
plot(datetime(tv), 0, 'o', 'Color', bL, 'MarkerFaceColor', bL, 'MarkerSize', 12)
set(gca, 'FontSize', 14, 'YGrid', 'on')
title('Fully Vaccinated', 'FontSize', 20)
legend('Model', 'Data', 'First Lockdown', 'Vaccination', 'Location', 'SouthEast')