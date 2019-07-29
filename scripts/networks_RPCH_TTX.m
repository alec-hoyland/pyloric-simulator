% for each model, kill all sodium channels by applying TTX

% load the data
allfiles = dir('data_optim_network_*.mat');

cost              = NaN(2e3,1);
metrics						= NaN(24,2e3);
metrics_MI 				= NaN(24,2e3);
params 						= NaN(29,2e3);

for ii = 1:length(allfiles)
	data = load(allfiles(ii).name);

	passing		 			= ~isnan(data.cost);
	data.cost 			= data.cost(passing);
	data.metrics 	  = data.metrics(:,passing);
	data.metrics_MI = data.metrics_MI(:,passing);
	data.params 		= data.params(:,passing);
	parameter_names = data.parameter_names;

	a = find(isnan(cost),1,'first');
	z = a + length(data.cost) - 1;

	% assemble
	cost(a:z) 			= data.cost;
	metrics(:,a:z) 	= data.metrics;
	metrics_MI(:,a:z) = data.metrics_MI;
	params(:,a:z) 	= data.params;
end

% trim
a 								= find(isnan(cost),1,'first');
cost 							= cost(1:a-1);
metrics 					= metrics(:,1:a-1);
metrics_MI 				= metrics_MI(:,1:a-1);
params 						= params(:,1:a-1);

% for each parameter set, add Swensen modulatory input to ABPD and LP and kill sodium
parameter_names(end) 		= {'AB.MICurrent.gbar'};
parameter_names(end+1) 	= {'LP.MICurrent.gbar'};
params(end+1,:) 				= params(end,:);

% create a network
make_stg
x.AB.add('swensen/MICurrent','gbar',0,'E',-22);
x.LP.add('swensen/MICurrent','gbar',0,'E',-22);

% run the network
Vtrace = cell(size(params,2),1);
for ii = 1:size(params,2)
	textbar(ii,size(params,2))
	x.set(parameter_names,params(:,ii));
	x.set(x.find('*NaV.gbar'),0);
	x.t_end = 300e3;
	x.integrate;
	x.t_end = 60e3;
	Vtrace{ii} = x.integrate;
end

save('data_RPCH_TTX.mat','Vtrace','params');

figure;
for ii = 1:3
	ax(ii) = subplot(3,1,ii);
	plot(NaN,NaN)
end
ylabel(ax(1),'V_{ABPD} (mV)')
ylabel(ax(2),'V_{LP} (mV)')
ylabel(ax(3),'V_{PY} (mV)')
xlabel(ax(3),'time (s)')
set(ax(1:2),'XTickLabel',{});
prettyFig();

for ii = 1:size(params,2)
	textbar(ii,size(params,2))
	for qq = 1:3
		plot(ax(qq),Vtrace{ii}(:,qq),'k')
	end
	suptitle(num2str(ii))
	equalizeAxes()
	saveas(gcf,['fig_RPCH_TTX_' num2str(ii) '.png'])
	pause(1)
end
