%% Model Simulation
% choose a bunch of models and simulate modulatory input in all of them
purpose = 'thesis'
% get the model parameters

if ~exist('data_characterize_IMI.mat')
  modelNames          = {'ABLP'}
  modelIndices        = {1:30};
  modelParams         = NaN(28,0);

  for qq = 1:length(modelNames)
    allfiles = dir(['data_optim_network_' modelNames{qq} '*.mat']);

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
    modelParams       = [modelParams params(1:28,:)];
  end

  % get the modulatory input matrix

  gMItrix             = allcomb([0 1], [0 1]);
  gMItrix             = gMItrix(2:end,:);       % μS/mm^2

  % create the network

  make_stg;
  % get the parameter names without IMI
  parameter_names     = x.find('*gbar');
  % get the compartment names
  % add IMI to ABPD and LP
  x.AB.add('swensen/MICurrent','gbar',0,'E',-22);
  x.LP.add('swensen/MICurrent','gbar',0,'E',-22);

  % simulate at various levels of modulatory input for each condition

  % set the number of simulations over modulatory input
  nSims               = 6;
  % create a vector of modulatory input
  gMI                 = linspace(0,1.0,nSims);

  % simulate

  % initialize output
  cost = NaN(length(gMI),size(gMItrix,1),size(modelParams,2));
  metrics = NaN(24,length(gMI),size(gMItrix,1),size(modelParams,2));

  % for each set of parameters
  counter = 0;
  for ii = 1:size(modelParams,2)
    % for each possible combination of IMI into cells
    for qq = 1:size(gMItrix,1)
      % for each maximal conductance of that IMI
      for ww = 1:length(gMI)
        counter = counter + 1; textbar(counter,numel(cost));
        % set the intrinsic and synaptic maximal conductances
        x.set(parameter_names,modelParams(:,ii));
        % set the modulatory input maximal conductances
        x.set(x.find('*MICurrent.gbar'),gMI(ww)*gMItrix(qq,:));
        % set initial conditions
        x.reset;
        % perform simulation
        [cost(ww, qq, ii), ~, metrics(:, ww, qq, ii)] = isPyloric(x,true);
      end
    end
  end

  save('data_characterize_IMI.mat','cost','metrics','parameter_names', ...
    'modelNames', 'modelParams', 'modelIndices', 'gMItrix', 'gMI')
else
  load('data_characterize_IMI.mat')
end

% all of the metrics are stored in a 4-D matrix
% metrics × gMI value × gMItrix index × model index
% 24 × length(gMI) × size(gMItrix,1) × size(modelParams,2)

% get burst frequency
burst_freq          = 1 ./ metrics(7:9, :, :, :);
% get duty cycle
duty_cycle          = metrics(10:12, :, :, :);
% get mean number of spikes per burst
nSpikes             = metrics(4:6, :, :, :);
% get minimum of the slow wave
min_slow_wave       = metrics(19:21, :, :, :);
% get maximum of the slow wave
max_slow_wave       = metrics(22:24, :, :, :);
% get amplitude
amplitude           = max_slow_wave - min_slow_wave;


% make plots of each of these metrics for each model
switch purpose
case 'thesis'
  passing = [4 5 8 30];
otherwise
  passing = 1:size(modelParams,2)
end

modelParams     = modelParams(:,passing);
burst_freq      = burst_freq(:,:,:,passing);
duty_cycle      = duty_cycle(:,:,:,passing);
nSpikes         = nSpikes(:,:,:,passing);
amplitude       = amplitude(:,:,:,passing);
c = linspecer(3);

% set up useful constants
nModels       = size(modelParams,2);
nSims         = 3;
nCells        = 3;

% instantiate gMI matrix
gMItrix       = zeros(2, nSims, nModels);
gMItrix(:,:,1) = [0, 0.2, 0.6; 0, 0, 0.6];
gMItrix(:,:,2) = [0, 0.8, 1; 0 0, 1];
gMItrix(:,:,3) = [0, 0, 1; 0, 0.4, 1];
gMItrix(:,:,4) = [0 0 1; 0 0.6 1];


% plot voltage over modulatory input
clear ax
if ~exist('data_characterize_V.mat')
  % create network
  make_stg
  x.AB.add('swensen/MICurrent','gbar',0,'E',-22);
  x.LP.add('swensen/MICurrent','gbar',0,'E',-22);
  x.PY.add('swensen/MICurrent','gbar',0,'E',-22);

  % instantiate simulation time

  % instantiate voltage matrix
  x.t_end       = 5e3;
  time          = (x.dt : x.dt : x.t_end)/1e3;
  V             = NaN(length(time), nCells, nSims, nModels);

  % perform simulation
  for ii = 1:nModels
    textbar(ii,nModels)
    % set the ionic and synaptic maximal conductances
    x.set(parameter_names, modelParams(:, ii));
    for qq = 1:nSims
      % set the modulatory input conductances
      x.reset;
      x.LP.MICurrent.gbar = gMItrix(1, qq, ii);
      x.AB.MICurrent.gbar = gMItrix(2, qq, ii);
      % simulate the model
      x.t_end = 20e3;
      x.integrate;
      % cut off the transient
      x.t_end = 5e3;
      V(:, :, qq, ii) = x.integrate;
    end
  end
  % save data
  save('data_characterize_V.mat','V','gMItrix','time');
else
  load('data_characterize_V.mat')
end

for ii = 1:nModels
  figure('PaperUnits', 'inches', 'PaperSize', [4 8]);
  clear ax;

  counter = 0;
  for qq = 1:3 % nCells
    for ww = 1:3 % nSims
      counter = counter + 1;
      ax(counter) = subplot(3, 3, counter);
      plot(time, squeeze(V(:, qq, ww, ii)), 'Color', c(qq,:));
      ylim(ax(counter),[-80 50]);
      box(ax(counter),'off');
    end
  end

  ylabel(ax(1),'AB-PD (mV)');
  ylabel(ax(4),'LP (mV)');
  ylabel(ax(7),'PY (mV)');

  for qq = 7:9
    xlabel(ax(qq),'time (s)');
  end

  equalizeAxes(ax(1:9));
  prettyFig('plw',1,'fs',30,'axis_box','off');

  % plot metrics over modulatory input
  figure('PaperUnits', 'inches', 'PaperSize', [4 8]);
  clear ax;
  % figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[2000 2000]);
  for qq = 1:12
    ax(qq) = subplot(4,3,qq);
    xlim(ax(qq),[0 1])
  end

  for qq = 1:3 % each arrangement of IMI
    idx = qq;

    hold(ax(idx), 'on')
    plot(ax(idx), gMI, squeeze(burst_freq(1, :, qq, ii)), '-o', 'Color', c(1,:));
    plot(ax(idx), gMI, squeeze(burst_freq(2, :, qq, ii)), '-o', 'Color', c(2,:));
    plot(ax(idx), gMI, squeeze(burst_freq(3, :, qq, ii)), '-o', 'Color', c(3,:));

    hold(ax(idx+3), 'on')
    plot(ax(idx+3), gMI, squeeze(duty_cycle(1, :, qq, ii)), '-o', 'Color', c(1,:));
    plot(ax(idx+3), gMI, squeeze(duty_cycle(2, :, qq, ii)), '-o', 'Color', c(2,:));
    plot(ax(idx+3), gMI, squeeze(duty_cycle(3, :, qq, ii)), '-o', 'Color', c(3,:));

    hold(ax(idx+6), 'on')
    plot(ax(idx+6), gMI, squeeze(nSpikes(1, :, qq, ii)), '-o', 'Color', c(1,:));
    plot(ax(idx+6), gMI, squeeze(nSpikes(2, :, qq, ii)), '-o', 'Color', c(2,:));
    plot(ax(idx+6), gMI, squeeze(nSpikes(3, :, qq, ii)), '-o', 'Color', c(3,:));

    hold(ax(idx+9), 'on')
    plot(ax(idx+9), gMI, squeeze(amplitude(1, :, qq, ii)), '-o', 'Color', c(1,:));
    plot(ax(idx+9), gMI, squeeze(amplitude(2, :, qq, ii)), '-o', 'Color', c(2,:));
    plot(ax(idx+9), gMI, squeeze(amplitude(3, :, qq, ii)), '-o', 'Color', c(3,:));

    for ww = 1:nSims
      if gMItrix(1,ww,ii) ~= 0 & gMItrix(2,ww,ii) == 0
          xpoint = squeeze(gMItrix(1,ww,ii));
          plot(ax(1), [xpoint xpoint], [min(vectorise(burst_freq)) max(vectorise(burst_freq))],':k');
          plot(ax(4), [xpoint xpoint], [min(vectorise(duty_cycle)) max(vectorise(duty_cycle))],':k');
          plot(ax(7), [xpoint xpoint], [min(vectorise(nSpikes)) max(vectorise(nSpikes))],':k');
          plot(ax(10), [xpoint xpoint], [min(vectorise(amplitude)) max(vectorise(amplitude))],':k');
      elseif gMItrix(2,ww,ii) ~= 0 & gMItrix(1,ww,ii) == 0
        xpoint = squeeze(gMItrix(2,ww,ii));
        plot(ax(2), [xpoint xpoint], [min(vectorise(burst_freq)) max(vectorise(burst_freq))],':k');
        plot(ax(5), [xpoint xpoint], [min(vectorise(duty_cycle)) max(vectorise(duty_cycle))],':k');
        plot(ax(8), [xpoint xpoint], [min(vectorise(nSpikes)) max(vectorise(nSpikes))],':k');
        plot(ax(11), [xpoint xpoint], [min(vectorise(amplitude)) max(vectorise(amplitude))],':k');
      elseif gMItrix(2,ww,ii) ~= 0 & gMItrix(1,ww,ii) ~= 0
        xpoint = squeeze(gMItrix(2,ww,ii));
        plot(ax(3), [xpoint xpoint], [min(vectorise(burst_freq)) max(vectorise(burst_freq))],':k');
        plot(ax(6), [xpoint xpoint], [min(vectorise(duty_cycle)) max(vectorise(duty_cycle))],':k');
        plot(ax(9), [xpoint xpoint], [min(vectorise(nSpikes)) max(vectorise(nSpikes))],':k');
        plot(ax(12), [xpoint xpoint], [min(vectorise(amplitude)) max(vectorise(amplitude))],':k');
      end
    end
  end

  for qq = 1:12
    box(ax(qq),'off');
  end

  ylabel(ax(1),{'burst frequency'; '(Hz)'})
  ylabel(ax(4),'duty cycle')
  ylabel(ax(7),'spikes per burst')
  ylabel(ax(10),{'slow wave', 'amplitude', '(mV)'})

  for qq = 9:12
    xlabel(ax(qq),'ḡ_{MI} (\muS/mm^2)')
  end

  title(ax(1),{'';'Modulation onto';'LP'})
  title(ax(2),{'';'Modulation onto';'AB-PD'})
  title(ax(3),{'';'Modulation onto';'AB-PD & LP'})

  set(ax(1:3),'YLim',[min(vectorise(burst_freq)) max(vectorise(burst_freq))])
  set(ax(4:6),'YLim',[min(vectorise(duty_cycle)) max(vectorise(duty_cycle))])
  set(ax(7:9),'YLim',[min(vectorise(nSpikes)) max(vectorise(nSpikes))])
  set(ax(10:12),'YLim',[min(vectorise(amplitude)) max(vectorise(amplitude))])

  legend(ax(1),{'AB-PD','LP','PY'},'Location','best'); legend boxoff

  % suptitle(num2str(ii))
  % tightfig();
  % saveas(gcf,['characterize_IMI_metrics_' num2str(ii)],'eps')

  set(gcf, 'PaperUnits', 'inches');
  set(gcf, 'PaperPosition', [0 0 4.25 8]);
  set(gcf,'PaperPositionMode','auto')

  prettyFig('fs',18,'plw',2);
  % tightfig();

  % print(gcf, ['plot' num2str(ii)], '-depsc', '-tiff')
end
