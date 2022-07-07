clear 
close all
clc

my_config_ETH.p         = 1;   % how beta and alpha are chosen 
my_config_ETH.Ne        = 20;  % default is 20
my_config_ETH.w         = 0.0001;
my_config_ETH.clamp     = 1.e-10;
my_config_ETH.anamorph  = false;
my_config_ETH.inflate   = 1.00;
my_config_ETH.filter    = 'EAKF';
my_config_ETH.data_type = 'AR';
my_config_ETH.results   = false; 

%set to false when doing senstivity runs --> true shows state evol.

%[model, da, obs, diags, state] = DA_exps_(my_config); % was commented

%% inflation sensitivity

disp ('RUNNING SENSITIVITY TEST FOR INFLATION' )
infvals = 1.00:0.01:1.02;
Ni      = length(infvals);

% sprintf('\n')

% Loop to print experiments and inflation values
for i = 1:Ni    

    disp(['Experiment: ' num2str(i) ', inflation: ' num2str(infvals(i))])

    % change inflation value
    my_config_ETH.inflate = infvals(i);

    % now, run DA:
    [model, da, obs, diags(i), state(i)] = DA_exps_ETH(my_config_ETH);
end

% Plot

C = parula(Ni); % returns a cm as a 3 clm array with the same nr c m forcurrent figure.

figure('Position', [10, 10, 1400, 440])

nr = 1; % number of rows
nc = 2; % number of columns

leg_text = cell(Ni, 1); 

for o = 1:da.Ny

    subplot(nr, nc, o) 

    plot(model.time, diags(1).RMSE(o, :), '*','Color', 'k', 'MarkerSize', 6); hold on 
    leg_text{1} = sprintf('SEIR Model (no DA), RMSE: %.3f', nanmean(diags(1).RMSE(o, :)/1e6)) ;

    for i = 1:Ni
        plot(model.time, diags(i).RMSEf(o, :),'*', 'Color', C(i, :), 'MarkerSize', 6); 
        leg_text{i+1} = sprintf('DA; inf: %.3f, RMSE: %.3f', infvals(i), nanmean(diags(i).RMSEf(o, :)/1e6));
    end
    set(gca, 'FontSize', 16, 'YGrid', 'on')
    ylabel('Skill', 'FontSize', 18)
    title(model.varnames(da.vars(o)), 'FontSize', 20)
    legend(leg_text)
end


%% Different filters

disp ('RUNNING SENSITIVITY TEST FOR DIFFERENT FILTERS')
filters = {'EAKF', 'EnKF', 'RHF'};
Ni      = length(filters);

for i = 1:Ni    

    disp(['Experiment: ' num2str(i) ', filter: ' filters{i}])

    % change inflation value
    my_config_ETH.filter = filters{i};

    % now, run DA:
    [model, da, obs, diags(i), state(i)] = DA_exps_ETH(my_config_ETH);
end

C = parula(Ni);

figure('Position', [10, 10, 1200, 440])

nr = 2;
nc = 2;

leg_text = cell(Ni, 1);
for o = 1:da.Ny

    subplot(nr, nc, o) 

    plot(model.time, diags(1).RMSE(o, :), 'Color', 'k', 'LineWidth', 2); hold on 
    leg_text{1} = sprintf('SEIR Model (no DA), RMSE: %.3f', nanmean(diags(1).RMSE(o, :)/1e6)) ;

    for i = 1:Ni
        plot(model.time, diags(i).RMSEf(o, :), 'Color', C(i, :), 'LineWidth', 2); 
        leg_text{i+1} = sprintf('DA: %s, RMSE: %.3f', filters{i}, nanmean(diags(i).RMSEf(o, :)/1e6));
    end
    set(gca, 'FontSize', 16, 'YGrid', 'on')
    ylabel('Skill', 'FontSize', 18)
    title(model.varnames(da.vars(o)), 'FontSize', 20)
    legend(leg_text)
end

%% Number of Ensembles 


Evals = [20, 50, 100];
Ni = length(Evals);

disp ( 'RUNNING SENSITIVITY TEST FOR DIFFERENT NUMBER OF ENSEMBLES') 

for i = 1:Ni

    display (['Experiment ', num2str(i), ', Number of ensembles: ', num2str(Evals(i))])

    % change ensemble value
    my_config_ETH.Ne = Evals(i);

    % now, run DA:
    [model, da, obs, diags(i), state(i)] = DA_exps_ETH(my_config_ETH);
end

C = parula(Ni); % returns a cm as a 3 clm array with the same nr cm for current figure.

figure('Position', [10, 10, 1400, 440])

nr = 2; % number of rows
nc = 2; % number of columns

leg_text = cell(Ni, 1); 

for o = 1:da.Ny

    subplot(nr, nc, o) 

    plot(model.time, diags(1).RMSE(o, :), 'Color', 'k', 'LineWidth', 2); hold on 
    leg_text{1} = sprintf('SEIR Model (no DA), RMSE: %.3f', nanmean(diags(1).RMSE(o, :)/1e6)) ;

    for i = 1:Ni
        plot(model.time, diags(i).RMSEf(o, :), 'Color', C(i, :), 'LineWidth', 2); 
        leg_text{i+1} = sprintf('DA; Ne: %.1f, RMSE: %.3f', Evals(i), nanmean(diags(i).RMSEf(o, :)/1e6));
    end
    set(gca, 'FontSize', 16, 'YGrid', 'on')
    ylabel('Skill', 'FontSize', 18)
    title(model.varnames(da.vars(o)), 'FontSize', 20)
    legend(leg_text)

    
end

%% Anamorphosis

disp ('RUNNING SENSITIVITY TEST FOR ANAMORPHOSIS') %not necessary...

anamorph = {'true', 'false'};
Ni = length(anamorph);

disp ( 'RUNNING SENSITIVITY TEST FOR ANAMORPHOSIS') 

for i = 1:Ni

    display (['Experiment ', num2str(i), ', Anamorphosis: ', (anamorph{i})])

    % change anamorph value
    my_config_ETH.anamorph = anamorph{i};

    % now, run DA:
    [model, da, obs, diags(i), state(i)] = DA_exps_ETH(my_config_ETH);
end

% Plot
C = parula(Ni); % returns a cm as a 3 clm array with the same nr cm for current figure.

figure('Position', [10, 10, 1400, 440])

nr = 2; % number of rows
nc = 2; % number of columns

leg_text = cell(Ni, 1); 

for o = 1:da.Ny

    subplot(nr, nc, o) 

    plot(model.time, diags(1).RMSE(o, :), 'Color', 'k', 'LineWidth', 2); hold on 
    leg_text{1} = sprintf('SEIR Model (no DA), RMSE: %.3f', nanmean(diags(1).RMSE(o, :)/1e6)) ;

    for i = 1:Ni
        plot(model.time, diags(i).RMSEf(o, :), 'Color', C(i, :), 'LineWidth', 2); 
        leg_text{i+1} = sprintf('DA; RMSE: %.3f', anamorph{i}, nanmean(diags(i).RMSEf(o, :)/1e6));
    end
    set(gca, 'FontSize', 16, 'YGrid', 'on')
    ylabel('Skill', 'FontSize', 18)
    title(model.varnames(da.vars(o)), 'FontSize', 20)
    legend(leg_text)

    
end




