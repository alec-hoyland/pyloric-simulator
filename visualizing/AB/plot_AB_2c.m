% visualize data for networks from the Prinz database (Prinz et al. 2004)
% with modulatory input (Swensen & Marder 2001)
pHeader;
being_published = 0;

%% Data
% These data represent three-cell Prinz models (ABPD, LP, PY) in which AB is
% subjected to Swensen modulatory input conductance (Prinz _et al._ 2003, 2004;
% Swensen & Marder 2000, 2001). A canonical seed taken from figure 2e in the 2004
% paper (with ABPD #1 instead) was used as a starting point.
% 100 trials using this seed were simulated.
%
% The optimizer accepted the synaptic conductances as parameters. The cost function
% required the following changes in burst metrics over the modulatory input
% maximal conductance.
%
%
% From this, we gather the following ratios between non-modulated and modulated cases:
% * *Duty Cycle:* 1.0
% * *Burst Frequency:* 1.5
% Since amplitude change is a signed value, we opted to use a difference formula instead.
% * *Slow-Wave Minimum:* -5 mV
% * *Slow-Wave Maximum:* +5 mV
%
% The models were simulated for 20 s with a time-step of 0.1 ms using the ``fast-Prinz''
% conductances. The first 5 s of simulation were discarded as transient. Burst metrics
% were computed with |psychopomp| functions, except for the maximal slow-wave, which
% was computed by a Savitzky-Golay filter on the voltage trace with a window of 300 ms.


% load the data
load('data_optim_AB_2c_chaos.mat');
nModels       = sum(~isnan(cost));

% get burst frequency
burst_freq    = NaN(2,nModels);
burst_freq(1,:) = metrics(1,1:nModels);
burst_freq(2,:) = metrics_MI(1,1:nModels);

% get duty cycle
duty_cycle    = NaN(2,nModels);
duty_cycle(1,:) = metrics(2,1:nModels);
duty_cycle(2,:) = metrics_MI(2,1:nModels);

% get min slow wave
min_slow_wave = NaN(2,nModels);
min_slow_wave(1,:) = metrics(3,1:nModels);
min_slow_wave(2,:) = metrics_MI(3,1:nModels);

% get max slow wave
max_slow_wave = NaN(2,nModels);
max_slow_wave(1,:) = metrics(4,1:nModels);
max_slow_wave(2,:) = metrics_MI(4,1:nModels);

% get gMI values
gMItrix       = [ zeros(1, nModels); params( find(contains(parameter_names,'Neurite.MICurrent.gbar')), 1:nModels ) ];

% get amplitude
amplitude     = max_slow_wave - min_slow_wave;


%% Normalized Metrics
% Each metric was evaluated by change from baseline. In the case of all metrics
% excepting amplitude, this is expressed as a dimensionless ratio. For amplitude
% the different in amplitudes between modulated and baseline case was used.


% compute metrics of change by normalizing by control conditions (gMI = 0)
norm_duty     = duty_cycle(:,:,:) ./ duty_cycle(1,:,:);
norm_freq     = burst_freq(:,:,:) ./ burst_freq(1,:,:);
delta_amp     = amplitude(:,:,:) - amplitude(1,:,:);

% plot the data
figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1500 1000]);
for ii = 1:4
  ax(ii) = subplot(2,2,ii);
end
% plot data
plot(ax(1),gMItrix,norm_freq,'-o');
plot(ax(2),gMItrix,norm_duty,'-o')
plot(ax(4),gMItrix,delta_amp,'-o');

% add labels
% burst-frequency
title(ax(1),'norm. burst frequency');
xlabel(ax(1),'$\bar{g}_{MI}^{AB} (\mu S/mm^2)$','interpreter','latex')
ylabel(ax(1),'norm. burst frequency')
xlim(ax(1),[-0.2 1.2])
% duty cycle
title(ax(2),'norm. duty cycle');
xlabel(ax(2),'$\bar{g}_{MI}^{AB} (\mu S/mm^2)$','interpreter','latex')
ylabel(ax(2),'norm. duty cycle')
% number of spikes
title(ax(3),'norm. spikes per burst');
xlabel(ax(3),'$\bar{g}_{MI}^{AB} (\mu S/mm^2)$','interpreter','latex')
ylabel(ax(3),'norm. spikes per burst')
% phase difference
title(ax(4),'change in amplitude');
xlabel(ax(4),' Δ amplitude (mV)')
xlim(ax(4),[-0.2 1.2])

equalizeAxes(ax(1:3));
prettyFig()

if being_published
  snapnow
  delete(gcf)
end


%% Dose-Response Curves
% ABPD is shown here, over six values of modulatory input.


x = make2C;
x.Neurite.add('swensen/MICurrent','gbar',0.5,'E',-22);
x.Soma.add('swensen/MICurrent','gbar',0.5,'E',-22);
x.transpile; x.compile;

time          = (x.dt:x.dt:x.t_end)/1e3;
nSims         = 3;
clear ax

for ii = 1:nModels
  V           = NaN(length(time),nSims);
  gMI         = linspace(0,params(end,ii),nSims);
  % simulate the voltage
  for qq = 1:nSims
    % set the parameters
    x.set(parameter_names,params(:,ii));
    % set the maximal conductance
    x.set(x.find('*MICurrent.gbar'),gMI(qq));
    % clone the conductances in the somatic compartment
    x.set(x.find('Soma*gbar'),x.get(x.find('Neurite*gbar')));
    % Remove NaV in the somatic compartment
    x.Soma.NaV.gbar = 0;
    % integrate and store the voltage trace
    Vtrace     = x.integrate;
    V(:,qq)    = Vtrace(:,1);
  end

  figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
  for qq = 1:nSims
    ax(qq) = subplot(nSims,1,qq);
    plot(ax(qq),time,V(:,qq),'k')
    ylabel({'g_{MI}'; num2str(gMI(qq),2)})
  end

  equalizeAxes(); prettyFig()

  xlabel(ax(3),'time (s)')
  set(ax(1:end-1),'XTickLabel',{})
  set(ax(:),'XLim',[0.75*max(time) max(time)]);
  set(ax(:),'YLim',[1.2*min(vectorise(V)) 1.2*max(vectorise(V))]);
  suptitle('Dose-Response Traces for ABPD')

  if being_published
    snapnow
    delete(gcf)
  end
end
