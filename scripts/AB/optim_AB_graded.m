% "From life's school of war: what does not kill me makes me stronger"
% -- Friedrich Nietzsche, Twilight of the Idols, or, How to Philosophize with a Hammer

% take neurons from the Prinz database without NaV or CaT which have been filtered
% excitatory perturbation by Swensen modulatory input conductance
% initial conditions are V = 60 mV, m_{MI} = 1
% run through a procrustes simulation for each new seed

% create the pacemaker
create_AB

% % using new cpplab xolotl
p 					= procrustes('particleswarm');
p.x 				= x;

% add parameters to vary
parameter_names = x.find('*gbar');
x.set(parameter_names,[999.99       58.217      0.18051       99.937         1998])

% insert modulatory input
% add modulatory input
x.AB.add('swensen/MICurrent','gbar',0,'E',-22);

% neuron conductances
p.lb       	= 0.1*[999.99       58.217      0.18051       99.937         1998]
p.ub 	      = 2*[999.99       58.217      0.18051       99.937         1998];

% set procrustes options
p.parameter_names 	= parameter_names;
p.options.MaxTime 	= 300;
p.sim_func 					= @AB_simulation_function;
if strcmp(getComputerName,'gilgamesh') | strcmp(getComputerName,'enkidu')
  p.options.SwarmSize = 32;
else
  p.options.SwarmSize = 24;
end

% initialize simulaton parameters
nSims				= 30;
nEpochs 		= 3;
nParams 		= length(p.parameter_names);
params 			= NaN(nParams,nSims);
filename  	= ['data_optim_AB_graded_short_' getComputerName '.mat'];

% initialize outputs
cost 					= NaN(1,nSims);
burst_freq 		= NaN(6,nSims);
duty_cycle 		= NaN(6,nSims);
min_slow_wave	= NaN(6,nSims);
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
		p.seed = [500 60 0.1 50 1000];

		% run procrustes
		for qq = 1:nEpochs
			p.fit;
		end

		% save
		x.set(p.parameter_names,p.seed);
		params(:,ii) = p.seed;

		[cost(ii), burst_freq(:,ii), duty_cycle(:,ii), min_slow_wave(:,ii), max_slow_wave(:,ii)] = AB_simulation_function(x);

		save(filename,'cost','burst_freq','duty_cycle','min_slow_wave','max_slow_wave','params');
		disp(['saved simulation ' num2str(ii)])

	catch
		disp('Something went wrong. Ouch.')
	end

end

disp('DONE!!!')
