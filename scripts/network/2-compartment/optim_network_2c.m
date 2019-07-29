
% for gilgamesh run
create_network_2c;
p = procrustes('particleswarm');
p.x = x;

% load('~/code/pyloric-simulator/data/network/params2vary.mat')
% hard-core parameters to vary
params2vary = {'AB.ACurrent.gbar', 'AB.CaS.gbar', 'AB.CaT.gbar', ...
	'AB.HCurrent.gbar', 'AB.KCa.gbar', 'AB.Kd.gbar', 'AB.NaV.gbar',  ...
	'LP.ACurrent.gbar', 'LP.CaS.gbar', 'LP.CaT.gbar', 'LP.HCurrent.gbar',  ...
	'LP.KCa.gbar', 'LP.Kd.gbar', 'LP.NaV.gbar', 'PY.ACurrent.gbar',  ...
	'PY.CaS.gbar', 'PY.CaT.gbar', 'PY.HCurrent.gbar', 'PY.KCa.gbar', ...
	'PY.Kd.gbar', 'PY.NaV.gbar', 'synapses(1).gbar', 'synapses(2).gbar', ...
	 'synapses(3).gbar', 'synapses(4).gbar', 'synapses(5).gbar',  ...
	 'synapses(6).gbar', 'synapses(7).gbar'};

% filter reprinz simulations to find good seeds
load('reprinz_dalek.bio.brandeis.edu.mat')
seed = all_g(:,find(all_cost == 0));

p.parameter_names   = params2vary;
% seed 								= [x.getConductances(1); x.getConductances(2); x.getConductances(3); [x.synapses(1:7).gbar]'];
% x.AB.MICurrent.gbar = .5;


% neuron conductances
ub = 0*size(seed,1);
lb = 0*size(seed,1);
ub(1:21) = repmat([500; 100; 100; .5; 100; 1250; 2000],3,1);
lb(1:21) = 1e-2;
% synapses
ub(22:28) = 100; % nS
lb(22:28) = 0; % nS

p.seed = seed(:,1);

setParams(p.x,p.seed,p.parameter_names);
p.lb = lb;
p.ub = ub;

% cost function
p.sim_func = @network_simulation_function_2c;


N = 100;
n_epochs = 3;
all_g = NaN(28,N);
all_metrics = NaN(18,N);
all_cost = NaN(N,1);

file_name = ['reprinz_2c_' 'gilgamesh' '.mat'];

if exist(file_name)
	load(file_name)
end

p.options.MaxTime = 300;
p.options.SwarmSize = 32;

% run procrustes
for i = 1:N

	try
		% set seed
		p.seed = seed(:,randi(size(seed,1)));

		% run procrustes
		for j = 1:n_epochs
			p.fit;
		end

		% save
		setParams(x,p.seed,p.parameter_names);
		[all_cost(i),~,all_metrics(:,i)] = p.sim_func(x);

		all_g(:,i) = p.seed;


		save(file_name,'all_g','all_metrics','all_cost')

	catch
		disp('Something went wrong. Ouch. ')
	end

end
