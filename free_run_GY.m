clear 
clc
% close all

rng('default') 

% period before/after lockdown
ti = '2020-01-22';   
tl = '2020-03-18'; 
tv = '2021-03-29';
tf = '2022-06-15';

my_config.p = 2;

% Time definition:
[model, x] = initialize_seir_exps_GY(ti, tl, tv, tf, my_config);

% Data:
[~, Active, Recovered, Deaths, Vaccinated] = read_data_GY;


% Model run: 
X = zeros(model.Nx, model.Nt);
for k = 1:model.Nt

    if model.p == 1
        if k <= model.Nt1
            model.beta = model.beta1; 
        else
            model.beta = model.beta2; 
        end

        if k > model.Nt2 
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

subplot(221)
plot(model.time, X(4, :), 'Color', bL, 'LineWidth', 2); hold on 
plot(model.time, Active, '.k')
plot(datetime(tl), 0, 'o', 'Color', rD, 'MarkerFaceColor', rD, 'MarkerSize', 12)
plot(datetime(tv), 0, 'o', 'Color', gR, 'MarkerFaceColor', gR, 'MarkerSize', 12)
set(gca, 'FontSize', 14, 'YGrid', 'on')
title('Active Cases', 'FontSize', 20)
legend('Model', 'Data', 'First Lockdown', 'Vaccination', 'Location', 'NorthEast')

subplot(222)
plot(model.time, X(5, :), 'Color', bL, 'LineWidth', 2); hold on 
plot(model.time, Recovered, '.k')
plot(datetime(tl), 0, 'o', 'Color', rD, 'MarkerFaceColor', rD, 'MarkerSize', 12)
plot(datetime(tv), 0, 'o', 'Color', gR, 'MarkerFaceColor', gR, 'MarkerSize', 12)
set(gca, 'FontSize', 14, 'YGrid', 'on')
title('Recovered Cases', 'FontSize', 20)
legend('Model', 'Data', 'First Lockdown', 'Vaccination', 'Location', 'East')

subplot(223)
plot(model.time, X(6, :), 'Color', bL, 'LineWidth', 2); hold on 
plot(model.time, Deaths, '.k')
plot(datetime(tl), 0, 'o', 'Color', rD, 'MarkerFaceColor', rD, 'MarkerSize', 12)
plot(datetime(tv), 0, 'o', 'Color', gR, 'MarkerFaceColor', gR, 'MarkerSize', 12)
set(gca, 'FontSize', 14, 'YGrid', 'on')
title('Deaths', 'FontSize', 20)
legend('Model', 'Data', 'First Lockdown', 'Vaccination', 'Location', 'NorthWest')

subplot(224)
plot(model.time, X(7, :), 'Color', bL, 'LineWidth', 2); hold on 
plot(model.time, Vaccinated, '.k')
plot(datetime(tl), 0, 'o', 'Color', rD, 'MarkerFaceColor', rD, 'MarkerSize', 12)
plot(datetime(tv), 0, 'o', 'Color', gR, 'MarkerFaceColor', gR, 'MarkerSize', 12)
set(gca, 'FontSize', 14, 'YGrid', 'on')
title('Fully Vaccinated', 'FontSize', 20)
legend('Model', 'Data', 'First Lockdown', 'Vaccination', 'Location', 'SouthEast')