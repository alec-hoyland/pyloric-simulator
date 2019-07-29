% preamble
force = true;

% create the Prinzian circuit
create_pacemaker
x.t_end             = 40e3;     % ms
x.dt                = 0.1;      % ms
x.AB.MICurrent.gbar = 0.8;      % μS/mm^2
x.transpile;
x.compile;

% produce seed
seed                = zeros(9,5);
seed(:,1)           = 10*[400 2.5 6 50 10 100 0.01 0.00 0.08];
seed(:,2)           = 10*[100 2.5 6 50 5 100 0.01 0.00 0.08];
seed(:,3)           = 10*[200 2.5 4 50 5 50 0.01 0.00 0.08];
seed(:,4)           = 10*[200 5.0 4 40 5 125 0.01 0.00 0.08];
seed(:,5)           = 10*[300 2.5 2 10 5 125 0.01 0.00 0.08];


% produce 50 seeds and 50 random seeds
seed_matrix         = zeros(100,size(seed,1));
seed_matrix(1:50,:) = repmat(seed,[1,10])';
seed_matrix(51:end,:) = seed_matrix(1:50,:) .* (2*rand(size(seed_matrix(1:50,:))));

if ~exist('~/code/pyloric-simulator/data/procrustes_temp.mat') | force
    % initialize output
    pro_params = zeros(100,size(seed,1));
    % run procrustes
    for ii = 1:length(seed_matrix)
        textbar(ii,length(seed_matrix));
        % set up the procrustes object
        clear p;
        p                   = procrustes('particleswarm');
        p.x                 = x;
        p.options.MaxTime   = 600; % seconds
        p.parameter_names   = {'AB.NaV.gbar','AB.CaT.gbar','AB.CaS.gbar','AB.ACurrent.gbar', ...
                                'AB.KCa.gbar','AB.Kd.gbar','AB.H.gbar','AB.Leak.gbar',...
                                'AB.MICurrent.gbar'};
        p.seed              = seed_matrix(ii,:);
        % set the bounds for synapses
        p.lb                = 0 * ones(length(p.seed),1);
        p.ub                = 5e3 * ones(length(p.seed),1);
        p.sim_func          = @ABPD_Prinz_simulation_function;
        % fit parameters
        g = p.fit;
        % populate conductance-output
        pro_params(ii,:)    = g(:);
        save('~/code/pyloric-simulator/data/procrustes_temp.mat','pro_params')
    end
end

% run psychopomp on results
data = load('~/code/pyloric-simulator/data/procrustes_temp.mat')
% simulate these models and acquire metrics
clear p
p             = psychopomp;
p.cleanup;
p.n_batches   = 20;
p.x           = x;
params2vary   = {'AB.NaV.gbar','AB.CaT.gbar','AB.CaS.gbar','AB.ACurrent.gbar', ...
                        'AB.KCa.gbar','AB.Kd.gbar','AB.H.gbar','AB.Leak.gbar',...
                        'AB.MICurrent.gbar'};
all_params    = data.pro_params';
p.batchify(all_params,params2vary);
p.sim_func    = @prinz_simulation_function_AB;
p.simulate(1);
wait(p.workers)
% gather the data
[all_data, all_params] = p.gather;
cost          = all_data{1};
burst_freq    = all_data{2};
duty_cycle    = all_data{3};
nSpikes       = all_data{4};
min_slow_wave = all_data{5};
max_slow_wave = all_data{6};
params        = all_params;

save('~/code/pyloric-simulator/data/data_Prinz_ABPD_pro_sim.mat', ...
    'cost','burst_freq','duty_cycle','nSpikes','min_slow_wave', ...
    'max_slow_wave','params');
disp('saved data_Prinz_ABPD_pro_sim.mat')
