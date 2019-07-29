% plot_AB_graded
purpose = 'pdf';

allfiles = dir('data_optim_AB_graded_short_*.mat');

cost              = NaN(2e3,1);
burst_freq        = NaN(6,2e3);
duty_cycle        = NaN(6,2e3);
max_slow_wave     = NaN(6,2e3);
min_slow_wave     = NaN(6,2e3);
params            = NaN(5,2e3);

for ii = 1:length(allfiles)
  disp(allfiles(ii).name)
  data = load(allfiles(ii).name);

  passing		 			= ~isnan(data.cost);
  data.cost 			= data.cost(passing);
  data.params 		= data.params(:,passing);
  data.burst_freq = data.burst_freq(:,passing);
  data.duty_cycle 		= data.duty_cycle(:,passing);
  data.max_slow_wave 		= data.max_slow_wave(:,passing);
  data.min_slow_wave 		= data.min_slow_wave(:,passing);


  a = find(isnan(cost),1,'first');
  z = a + length(data.cost) - 1;

  % assemble
  cost(a:z) 			= data.cost;
  params(:,a:z) 	= data.params;
  burst_freq = data.burst_freq;
  duty_cycle 		= data.duty_cycle;
  max_slow_wave 		= data.max_slow_wave;
  min_slow_wave 		= data.min_slow_wave;
end

gMI           = linspace(0,1,6);

passing       = ~isnan(cost);
nModels       = sum(passing);
% params        = params(:,passing);
%
% cost          = cost(passing);
% burst_freq    = burst_freq(:,passing);
% max_slow_wave = max_slow_wave(:,passing);
% min_slow_wave = min_slow_wave(:,passing);
% duty_cycle    = duty_cycle(:,passing);

switch purpose
case 'pdf'
  passing = ~isnan(cost) & 1:size(params,2);
case 'thesis'
  passing = [];
otherwise
  passing = ~isnan(cost) & 1:size(params,2);
end

% plot the data
figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
for ii = 1:4
  ax(ii) = subplot(2,2,ii);
end

plot(ax(1),gMI,burst_freq);
plot(ax(2),gMI,duty_cycle);
plot(ax(3),gMI,max_slow_wave);
plot(ax(4),gMI,min_slow_wave);

create_AB
x.AB.add('swensen/MICurrent','gbar',0,'E',-22);

% figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
% hold on
% for ii = 1:size(params,2)
%   x.set(x.find('*gbar'),[params(:,ii); 0])
%   V = x.integrate;
%   plot(V);
% end
%
% figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
% hold on
% for ii = 1:size(params,2)
%   x.set(x.find('*gbar'),[params(:,ii); 0])
%   x.AB.MICurrent.gbar = 1.0;
%   V = x.integrate;
%   plot(V);
% end

% visualize color-maps of metrics
figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1500 1000]);
% plot data
[~, idx] = sort(mean(burst_freq));
gMI = linspace(0,0.2,6);
amplitude = max_slow_wave - min_slow_wave;

ax(1) = subplot(2,2,1); imagesc(1:30,gMI,burst_freq(:,idx));
ax(2) = subplot(2,2,2); imagesc(1:30,gMI,amplitude(:,idx));
ax(3) = subplot(2,2,3); imagesc(1:30,gMI,max_slow_wave(:,idx));
ax(4) = subplot(2,2,4); imagesc(1:30,gMI,min_slow_wave(:,idx));
% add labels etc.
for ii = 1:length(ax)
  xlabel(ax(ii),'neuron index');
  ylabel(ax(ii),'$\bar{g}_{MI} (\mu S/mm^2)$','interpreter','latex');
  set(ax(ii),'YDir','normal');
  C(ii) = colorbar(ax(ii));
end
C(1).Label.String = 'burst frequency (mV)'; caxis(ax(1), [min(vectorise(burst_freq)) max(vectorise(burst_freq))]);
C(2).Label.String = 'amplitude (mV)'; caxis(ax(2),[min(vectorise(amplitude)) max(vectorise(amplitude))]);
C(3).Label.String = 'volt peaks (mV)'; caxis(ax(3),[min(vectorise(max_slow_wave)) max(vectorise(max_slow_wave))]);
C(4).Label.String = 'volt troughs (mV)'; caxis(ax(4),[min(vectorise(min_slow_wave)) max(vectorise(min_slow_wave))]);
prettyFig()


%% Make Correlation Plots


% parameters from particle swarm
% remove NaN plots
params_optim = params(1:5,1:30); % A, CaS, H, KCa, Kd, MI

% parameters from Prinz 2003
data = load('data_Prinz_bursting_TTX_CaT_nosc_gMI_Swensen.mat')
params_Prinz(1,:) = data.params(4,:);
params_Prinz(2,:) = data.params(3,:);
params_Prinz(3,:) = data.params(7,:);
params_Prinz(4,:) = data.params(5,:);
params_Prinz(5,:) = data.params(6,:);

% parameters from Prinz 2003, optimized using gradient descent
data = load('data_Prinz_bursting_TTX_CaT_nosc_gMI_Swensen_ex_pro_sim.mat')
params_expro(1,:) = data.params(4,:);
params_expro(2,:) = data.params(3,:);
params_expro(3,:) = data.params(7,:);
params_expro(4,:) = data.params(5,:);
params_expro(5,:) = data.params(6,:);

% make histograms of each condition
figure; clear ax;
for ii = 1:25
  ax(ii) = subplot(5,5,ii);
  hold(ax(ii), 'on')
end

% set axis labels
cond_names = {'A', 'CaS', 'H', 'KCa', 'Kd'};
for ii = 1:5
  xlabel(ax(20+ii), cond_names{ii});
  ylabel(ax(5*(ii-1)+1), cond_names{ii});
end

% create histograms along the top-left to bottom-right diagonal
c = linspecer(3);
for ii = 1:5
  index = 5*(ii-1) + ii;

  [n h] = histcounts(params_optim(ii,:),30);
  center = h(1:end-1) + mean(diff(h));
  n = n / length(params_optim(ii,:));
  stairs(ax(index), center, n, 'Color', c(1,:));

  [n h] = histcounts(params_Prinz(ii,:),30);
  center = h(1:end-1) + mean(diff(h));
  n = n / length(params_Prinz(ii,:));
  stairs(ax(index), center, n, 'Color', c(2,:));

  % [n h] = histcounts(params_expro(ii,:),30);
  % center = h(1:end-1) + mean(diff(h));
  % n = n / length(params_expro(ii,:));
  % stairs(ax(index), center, n, 'Color', c(3,:));
end

% create correlations along the axes where ii ≢ qq
for ii = 1:5
  for qq = 1:5
    if ii ~= qq
      index = 5*(ii-1) + qq;
      % scatter(ax(index), params_expro(qq,:), params_expro(ii,:), 20, c(3,:), 'filled',  'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1);
      scatter(ax(index), params_Prinz(qq,:), params_Prinz(ii,:), 20, c(2,:), 'filled', 'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1);
      scatter(ax(index), params_optim(qq,:), params_optim(ii,:), 20, c(1,:), 'filled', 'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1);
    end
  end
end
