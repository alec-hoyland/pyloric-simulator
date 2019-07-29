% using new cpplab xolotl
make_stg;
p 					= procrustes('particleswarm');
p.x 				= x;

% add parameters to vary
parameter_names = x.find('*gbar');

% use new seeds
data 				= load('all_networks.mat')
seed 				= data.g(:,data.C == 0);

% insert modulatory input
% add modulatory input
x.AB.add('swensen/MICurrent','gbar',0.5,'E',-22);
x.transpile; x.compile;
parameter_names{end+1} = 'AB.MICurrent.gbar';
seed(end+1,:) = 0.5;

% neuron conductances
p.lb(1:29) 	= 0;
p.ub(1:21) 	= repmat([500; 100; 100; .5; 100; 1250; 2000],3,1);
p.ub(22:28) = 100;
p.ub(29) 		= 1;

% set procrustes options
p.parameter_names 	= parameter_names;
p.options.MaxTime 	= 900;
p.options.SwarmSize = 24;

% set seed
p.seed 			= seed(:,1);
% set parameters
x.set(p.parameter_names,p.seed);
% cost function
p.sim_func 	= @network_simulation_function;
% test cost function
p.sim_func(x)

% initialize outputs
nSims				= 30;
nEpochs 		= 3;
nParams 		= length(p.parameter_names);
params 			= NaN(nParams,nSims);
filename  	= ['data_optim_network_AB_' getComputerName '.mat'];
cost 				= NaN(1,nSims);
metrics 		= NaN(24,nSims);
metrics_MI 	= NaN(24,nSims);


if exist(filename)
	load(filename)
	start_idx = find(isnan(cost),1,'first');
else
	start_idx = 1;
end

% run procrustes
for ii = start_idx:nSims

% 	try
		% set seed
		p.seed = seed(:,randi(size(seed,2)));

		% run procrustes
		for qq = 1:nEpochs
			p.fit;
		end

		% save
		x.set(p.parameter_names,p.seed);
		params(:,ii) = p.seed;

		[cost(ii), metrics(:,ii), metrics_MI(:,ii)] = network_simulation_function(x);

		save(filename,'cost','metrics','metrics_MI','params','parameter_names');
		disp(['saved simulation ' num2str(ii)])

% 	catch
% 		disp('Something went wrong. Ouch.')
% 	end

end

disp('DONE!!!')
