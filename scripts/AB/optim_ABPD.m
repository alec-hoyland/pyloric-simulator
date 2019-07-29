% for gilgamesh run
create_AB;
p = procrustes('particleswarm');
p.x = x;

% hard-code parameters to vary
p.parameter_names = {'AB.CaS.gbar', 'AB.ACurrent.gbar', 'AB.KCa.gbar', ...
	'AB.Kd.gbar', 'AB.HCurrent.gbar', 'AB.Leak.gbar'};
seed 				= [100 1000 150 1000 2 0.1];


% neuron conductances
p.lb 				= zeros(length(seed),1);
p.ub 				= 2000 * ones(length(seed),1);
p.seed 			= seed;

% set procrustes options
p.options.MaxTime 	= 900;
p.options.SwarmSize = 24;

% cost function
p.sim_func 	= @AB_simulation_function;
% test cost function
p.sim_func(x)

% initialize outputs
nSims				= 30;
nEpochs 		= 3;
nParams 		= length(p.parameter_names);
params 			= NaN(nParams,nSims);
filename  	= ['data_optim_AB_' getComputerName '.mat'];
cost 				= NaN(1,nSims);
burst_freq	= NaN(6,nSims);
duty_cycle  = NaN(6,nSims);
min_slow_wave = NaN(6,nSims);
max_slow_wave = NaN(6,nSims);


if exist(filename)
	load(filename)
	start_idx = find(isnan(cost),1,'first');
else
	start_idx = 1;
end

% run procrustes
for ii = start_idx:nSims

	try
		% set seed
		p.seed = seed;

		% run procrustes
		for qq = 1:nEpochs
			p.fit;
		end

		% save
		params(:,ii) = p.seed;
		[cost(ii), burst_freq(:,ii), duty_cycle(:,ii), min_slow_wave(:,ii), max_slow_wave(:,ii)] = AB_simulation_function(x);
		save(filename,'cost','burst_freq','duty_cycle','min_slow_wave','max_slow_wave','params');
		disp(['saved simulation ' num2str(ii)])

	catch
		disp('Something went wrong. Ouch.')
	end

end

disp('DONE!!!')
