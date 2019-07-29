% visualize data for 2-compartment networks
% produced from the "reprinz" cost function
% without modulatory input

%% Data
% These data represent three-cell Prinz models (ABPD, LP, PY)
% which contain auxiliary compartments which mimic the
% spike initiation compartments except that they lack fast
% sodium. In this sense, each cell (or cell composite) has
% a spike-initiation zone/axonal compartment and a soma/neurite
% compartment.
%
% The models were simulated for 20 s with a time-step of 0.1 ms.
% The first 5 s of simulations were discarded as transient.
%
% The tiered ``reprinz'' cost function was used to sample the
% models.


% load the data
data = load('reprinz_2c_gilgamesh.mat');
passing     = find(data.all_cost == 0);
cost        = data.all_cost(passing);
params      = data.all_g(:,passing);
metrics     = data.all_metrics(:,passing);

% extract metrics
duration    = metrics(1:3,:);
nSpikes     = metrics(4:6,:);
period      = metrics(7:9,:);
duty_cycle  = metrics(10:12,:);
delay       = metrics(16:18,:);

frequency   = 1 ./ period;
phase       = delay ./ period(1,:);

% plot the data
lgd         = {'ABPD','LP','PY'};
% set up figure with four subplots
figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
for ii = 1:4
  ax(ii) = subplot(2,2,ii);
end
% plot the data
hist(ax(1),frequency')
title(ax(1),'burst frequency')
xlabel(ax(1),'(Hz)')
hist(ax(2),duty_cycle')
title(ax(2),'duty cycle')
hist(ax(3),nSpikes')
title(ax(3),'# spikes per burst')
hist(ax(4),phase');
title(ax(4),'phase rel. to ABPD')
% beautify
prettyFig()
suptitle('Metrics')
legend(ax(1),lgd,'Location','best')
