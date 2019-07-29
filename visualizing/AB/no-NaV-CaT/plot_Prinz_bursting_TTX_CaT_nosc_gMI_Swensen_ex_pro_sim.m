% visualize models from the Prinz database optimzied for Swensen modulatory input conductance

% establish header
pHeader;


%% Introduction
% This code visualizes simulations over increasing modulatory input for Prinz models.
% The models can be found in the Prinz database (Prinz _et al._ 2003). All bursting models
% were selected and simulated in TTX conditions without transient low-threshold calcium
% e.g. $\bar{g}_{NaV} = \bar{g}_{CaT} = 0$. The models were stripped of NaV and CaT currents,
% and those with voltage oscillation amplitudes < 10 mV were simulated using
% Swensen modulatory input conductance (Swensen & Marder 2001). The initial conditions were modified
% so that $V_m = 0~\mathrm{mV}$ and $m_{MI} = 1$. The top 100 models were selected
% and run through a procrustes simulation to optimize for burst frequency, and amplitude.


createPrinz
data = load('data_Prinz_bursting_TTX_CaT_nosc_gMI_Swensen_ex_pro_sim.mat')

% clean the data
keep_this     = all((data.burst_freq < 3) & (data.volt_peaks > -60) & (data.volt_peaks < 0) & (data.volt_troughs > -60) & (data.volt_troughs < -30));
burst_freq    = data.burst_freq(:,keep_this);
volt_peaks    = data.volt_peaks(:,keep_this);
volt_troughs  = data.volt_troughs(:,keep_this);
amplitude     = volt_peaks - volt_troughs;
params        = data.params(:,keep_this);

% preamble
gMI           = linspace(0,2,21);
idx_plot      = 1:length(burst_freq);
index         = zeros(4,length(burst_freq));
[~,index(1,:)]= sort(mean(burst_freq));
[~,index(2,:)]= sort(mean(amplitude));
[~,index(3,:)]= sort(mean(volt_peaks));
[~,index(4,:)]= sort(mean(volt_troughs));


%% Visualizing Color-Maps of Metrics
% The burst-frequency was computed using the Hilbert transform. Amplitude measures
% the difference between the peak (maximal) voltage and trough (minimal) voltage.


% visualize color-maps of metrics
figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
% plot data
ax(1) = subplot(2,2,1); imagesc(idx_plot,gMI,burst_freq(:,index(1,:)));
ax(2) = subplot(2,2,2); imagesc(idx_plot,gMI,amplitude(:,index(2,:)));
ax(3) = subplot(2,2,3); imagesc(idx_plot,gMI,volt_peaks(:,index(3,:)));
ax(4) = subplot(2,2,4); imagesc(idx_plot,gMI,volt_troughs(:,index(4,:)));
% add labels etc.
for ii = 1:length(ax)
  xlabel(ax(ii),'neuron index');
  ylabel(ax(ii),'$\bar{g}_{MI} (\mu S/mm^2)$','interpreter','latex');
  set(ax(ii),'YDir','normal');
  C(ii) = colorbar(ax(ii));
end
C(1).Label.String = 'burst frequency (Hz)'; caxis(ax(1),[min(min(burst_freq(:,index(1,:)))) max(max(burst_freq(:,index(1,:))))]);
C(2).Label.String = 'amplitude (mV)'; caxis(ax(2),[min(min(amplitude(:,index(2,:)))) max(max(amplitude(:,index(2,:))))]);
C(3).Label.String = 'volt peaks (mV)'; caxis(ax(3),[min(min(volt_peaks(:,index(3,:)))) max(max(volt_peaks(:,index(3,:))))]);
C(4).Label.String = 'volt troughs (mV)'; caxis(ax(4),[min(min(volt_troughs(:,index(4,:)))) max(max(volt_troughs(:,index(4,:))))]);
suptitle('optimized Prinz bursting models w/o NaV, CaT')
prettyFig()

if being_published
  snapnow
  delete(gcf)
end


%% Metrics over Maximal Conductance
% It seems that the neurons are most responsive at the range [0.8 1.5]. For
% the sake of visualization, future plots of voltage will look at [1 1.5].
% The step up seems to be relatively sharp, which is not necessarily bad,
% especially considering how small the conductance tends to be.


figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
for ii = 1:4
  ax(ii) = subplot(4,1,ii);
end
plot(ax(1),gMI,burst_freq);
plot(ax(2),gMI,amplitude);
plot(ax(3),gMI,volt_peaks);
plot(ax(4),gMI,volt_troughs);

% add labels
% burst-frequency
ylabel(ax(1),'burst frequency (Hz)')
ylim(ax(1),[0 3])
% duty cycle
ylabel(ax(2),'amplitude (mV)')
ylim(ax(2),[0 60])
% number of spikes
ylabel(ax(3),'peaks (mV)')
ylim(ax(3),[-60 0])
% phase difference
xlabel(ax(4),'$\bar{g}_{MI} (\mu S/mm^2)$','interpreter','latex')
ylabel(ax(4),'troughs (mV)')
ylim(ax(4),[-60 0])

suptitle('optimized Prinz bursting models w/o NaV, CaT')
prettyFig()


%% "Zoom" Simulation
% The modulatory input conductance simulation of the optimized neuron
% parameters was repeated with a different set of maximal conductances for
% gMI. This set ranges from 0 to 1.5 but with 6 steps between 0 and .8 and
% 21 steps between 1.0 and 1.5. This permit us to look at the transitional
% region of interest.


data  = load('data_Prinz_bursting_TTX_CaT_nosc_gMI_Swensen_ex_pro_sim_zoom.mat')

% clean the data
keep_this     = all((data.burst_freq < 3) & (data.volt_peaks > -60) & (data.volt_peaks < 0) & (data.volt_troughs > -60) & (data.volt_troughs < -30));
burst_freq    = data.burst_freq(:,keep_this);
volt_peaks    = data.volt_peaks(:,keep_this);
volt_troughs  = data.volt_troughs(:,keep_this);
amplitude     = volt_peaks - volt_troughs;
params        = data.params(:,keep_this);

% preamble
gMI           = [linspace(0,0.8,5) linspace(1.0,1.5,21)];
idx_plot      = 1:length(burst_freq);
index         = zeros(4,length(burst_freq));
[~,index(1,:)]= sort(mean(burst_freq));
[~,index(2,:)]= sort(mean(amplitude));
[~,index(3,:)]= sort(mean(volt_peaks));
[~,index(4,:)]= sort(mean(volt_troughs));

%% Visualizing Color-Maps of Metrics (Zoom)
% TO BE WRITTEN

% visualize color-maps of metrics
figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
% plot data
ax(1) = subplot(2,2,1); imagesc(idx_plot,gMI,burst_freq(:,index(1,:)));
ax(2) = subplot(2,2,2); imagesc(idx_plot,gMI,amplitude(:,index(2,:)));
ax(3) = subplot(2,2,3); imagesc(idx_plot,gMI,volt_peaks(:,index(3,:)));
ax(4) = subplot(2,2,4); imagesc(idx_plot,gMI,volt_troughs(:,index(4,:)));
% add labels etc.
for ii = 1:length(ax)
  xlabel(ax(ii),'neuron index');
  ylabel(ax(ii),'$\bar{g}_{MI} (\mu S/mm^2)$','interpreter','latex');
  set(ax(ii),'YDir','normal');
  C(ii) = colorbar(ax(ii));
end
C(1).Label.String = 'burst frequency (Hz)'; caxis(ax(1),[min(min(burst_freq(:,index(1,:)))) max(max(burst_freq(:,index(1,:))))]);
C(2).Label.String = 'amplitude (mV)'; caxis(ax(2),[min(min(amplitude(:,index(2,:)))) max(max(amplitude(:,index(2,:))))]);
C(3).Label.String = 'volt peaks (mV)'; caxis(ax(3),[min(min(volt_peaks(:,index(3,:)))) max(max(volt_peaks(:,index(3,:))))]);
C(4).Label.String = 'volt troughs (mV)'; caxis(ax(4),[min(min(volt_troughs(:,index(4,:)))) max(max(volt_troughs(:,index(4,:))))]);
suptitle('optimized Prinz bursting models w/o NaV, CaT')
prettyFig()

if being_published
  snapnow
  delete(gcf)
end


%% Metrics over Maximal Conductance (Zoom)
% These characteristically sharp ``jumps'' seem to indicate a bistable system.
% See Swensen & Marder 2001 Figures 4 and 5.


figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
for ii = 1:4
  ax(ii) = subplot(4,1,ii);
end
plot(ax(1),gMI,burst_freq);
plot(ax(2),gMI,amplitude);
plot(ax(3),gMI,volt_peaks);
plot(ax(4),gMI,volt_troughs);

% add labels
% burst-frequency
ylabel(ax(1),'burst frequency (Hz)')
ylim(ax(1),[0 3])
% duty cycle
ylabel(ax(2),'amplitude (mV)')
ylim(ax(2),[0 60])
% number of spikes
ylabel(ax(3),'peaks (mV)')
ylim(ax(3),[-60 0])
% phase difference
xlabel(ax(4),'$\bar{g}_{MI} (\mu S/mm^2)$','interpreter','latex')
ylabel(ax(4),'troughs (mV)')
ylim(ax(4),[-60 0])

suptitle('optimized Prinz bursting models w/o NaV, CaT')
prettyFig()
linkaxes(ax,'x')

if being_published
  snapnow
  delete(gcf)
end

% traces

create_AB
x.AB.add('swensen/MICurrent','gbar',0,'E',-22);
x.dt                  = 50e-3;
x.t_end               = 20e3;
x.transpile;
x.compile;
x.closed_loop         = false;
x.skip_hash_check     = true;

% look at specific ranges of gMI
% most models seem to increase only over about 3 gMI steps (~ 0.5 μS/mm^2)
index = any(diff(amplitude(8:10,:)) > 5);
new_params = params(:,index);

% look in more detail at an interesting model
gMI = linspace(1.05,1.1,6);
x.setConductances(1,new_params(:,2));
time = x.dt:x.dt:x.t_end;
V = zeros(length(time),length(gMI));


%% Voltage Traces
% There is a rapid shift from quiescent to oscillatory behavior.


% voltage
for ii = 1:length(gMI)
  textbar(ii,length(gMI));
  x.reset;
  x.Prinz.MICurrent.gbar = gMI(ii);
  [current_trace(ii), V(:,ii)] = x.getCurrentTrace;
end

% current
transient = floor(0.5 * length(time));
time = time(transient:end);
V = V(transient:end,:);
for ii = 1:length(current_trace)
  current_trace{ii} = current_trace{ii}(transient:end,:);
end

% plot voltage
figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1500 1000]);
for ii = 1:3
  subplot(3,1,ii)
  plot(time,V(:,2*ii)); title(['gMI = ' num2str(gMI(2*ii))])
end
prettyFig(); equalizeAxes()
suptitle(mat2str(new_params(:,2)))

if being_published
  snapnow
  delete(gcf)
end


%% Current Traces
% The absolute value of the maximum of the current trace was plotted for each
% point on a ``zoomed in'' current vs. modulatory input maximal conductance graph.
% Unlike by taking the mean current, which washes out spikes in ion flux, this method
% demonstrates when a current becomes more important to the qualitative state of the
% neuron.



% plot current
figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
for ii = 1:length(gMI)
  current_mat(ii,:) = 0.0628 * abs(max(current_trace{ii}));
end
plot(gMI,current_mat(:,3:end));
xlabel('$\bar{g}_{MI} (\mu S/mm^2)$','interpreter','latex')
ylabel('current (nA)')
set(gca,'YScale','log')
legend('CaS','A','KCa','Kd','H','Leak','MI')
prettyFig();

if being_published
  snapnow
  delete(gcf)
end

% %% Version Info
% % The file that generated this document is called:
% % pFooter;
