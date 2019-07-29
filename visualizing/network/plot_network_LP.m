% visualize data for networks from the Prinz database (Prinz et al. 2004)
% with modulatory input (Swensen & Marder 2001)
pHeader;
being_published = 0;
purpose = 'thesis';

nSims 				= 6;

% load data
if ~exist('~/code/pyloric-simulator/data/thesis/data_plot_network_LP.mat')
	allfiles = dir('data_optim_network_LP*.mat');

	cost              = NaN(2e3,1);
	metrics						= NaN(24,2e3);
	metrics_MI 				= NaN(24,2e3);
	params 						= NaN(29,2e3);

	for ii = 1:length(allfiles)
		disp(allfiles(ii).name)
		data = load(allfiles(ii).name);

		passing		 			= ~isnan(data.cost);
		data.cost 			= data.cost(passing);
		data.params 		= data.params(:,passing);
		parameter_names = data.parameter_names;

		a = find(isnan(cost),1,'first');
		z = a + length(data.cost) - 1;

		% assemble
		cost(a:z) 			= data.cost;
		params(:,a:z) 	= data.params;
	end

	% trim
	a 								= find(isnan(cost),1,'first');
	params 						= params(:,1:a-1);

	% get selected models
	nModels       = size(params,2);

	% create xolotl object
	make_stg;
	x.LP.add('swensen/MICurrent','gbar',0.5,'E',-22);

	% initialize outputs
	nSims 				= 6;
	burst_freq    = NaN(nSims,3,nModels);
	duty_cycle    = NaN(nSims,3,nModels);
	nSpikes       = NaN(nSims,3,nModels);
	min_slow_wave = NaN(nSims,3,nModels);
	max_slow_wave = NaN(nSims,3,nModels);

	x.t_end 			= 5e3;
	time 					= 20e3 + x.dt : x.dt : 20e3 + x.t_end;
	V 						= NaN(length(time),3,2,nModels);
	x.t_end 			= 25e3;

	for ii = 1:nModels
		textbar(ii,nModels)
		x.set(parameter_names,params(:,ii));
		[~, metrics, V1, V2] = network_simulation_function(x,true);
		metrics = metrics';

		% get voltage trace
		V(:,:,1,ii)	= V1(end-length(time)+1:end,:);
		V(:,:,2,ii)	= V2(end-length(time)+1:end,:);

		% get burst frequency
		burst_freq(:,:,ii) = 1 ./ metrics(:,7:9);

		% get duty cycle
		duty_cycle(:,:,ii) = metrics(:,10:12);

		% get number of spikes per burst
		nSpikes(:,:,ii) = metrics(:,4:6);

		% get min slow wave
		min_slow_wave(:,:,ii) = metrics(:,19:21);

		% get max slow wave
		max_slow_wave(:,:,ii) = metrics(:,22:24);
	end

	% save data
	save('~/code/pyloric-simulator/data/thesis/data_plot_network_LP.mat', ...
		'V', 'burst_freq', 'duty_cycle', 'nSpikes', 'min_slow_wave', 'max_slow_wave', ...
		'params','parameter_names','nModels');
else
	load('~/code/pyloric-simulator/data/thesis/data_plot_network_LP.mat')
end

% get gMI values
for ii = 1:nModels
	gMItrix(:,ii) = linspace(0,params(find(contains(parameter_names,'LP.MICurrent.gbar')),ii),nSims);
end

% get amplitude
amplitude     = max_slow_wave - min_slow_wave;

switch purpose
  case 'pdf'
    passing = 1:size(params,2);
  case 'thesis'
    passing = [3 4 6 16 28];
end

plot_network;
