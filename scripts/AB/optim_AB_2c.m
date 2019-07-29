% using new cpplab xolotl
x = make2C;
p 					= procrustes('particleswarm');
p.x 				= x;

% add parameters to vary
parameter_names = x.find('Neurite*gbar');

% use new seeds
load('reprinz_2c_dalek.bio.brandeis.edu.mat')
seed = all_g(:,all_cost == 0);

% insert modulatory input
% add modulatory input
x.Soma.add('swensen/MICurrent','gbar',0.5,'E',-22);
x.Neurite.add('swensen/MICurrent','gbar',0.5,'E',-22);
x.transpile; x.compile;
parameter_names{end+1} = 'Neurite.MICurrent.gbar';
seed(end+1,:) = 0.5;

% set procrustes options
p.parameter_names 	= parameter_names;
p.ub 								= [500; 100; 100; .5; 100; 1250; 2000; 1];
p.lb 								= p.ub*0 + 1e-2;
p.options.MaxTime 	= 900;
p.options.SwarmSize = 24;

% set seed
p.seed 			= seed(:,1);
% set parameters
x.set(p.parameter_names,p.seed);
% cost function
p.sim_func 	= @AB_simulation_function_2c;
% test cost function
p.sim_func(x)

% initialize outputs
nSims				= 30;
nEpochs 		= 3;
nParams 		= length(p.parameter_names);
params 			= NaN(nParams,nSims);
filename  	= ['data_optim_AB_2c_' getComputerName '.mat'];
cost 				= NaN(1,nSims);
metrics 		= NaN(4,nSims);
metrics_MI 	= NaN(4,nSims);


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
		p.seed = seed(:,randi(length(seed)));

		% run procrustes
		for qq = 1:nEpochs
			p.fit;
		end

		% save
		x.set(p.parameter_names,p.seed);
		params(:,ii) = p.seed;

		[cost(ii), metrics(:,ii), metrics_MI(:,ii)] = AB_simulation_function_2c(x);

		save(filename,'cost','metrics','metrics_MI','params','parameter_names');
		disp(['saved simulation ' num2str(ii)])

	catch
		disp('Something went wrong. Ouch.')
	end

end

disp('DONE!!!')
