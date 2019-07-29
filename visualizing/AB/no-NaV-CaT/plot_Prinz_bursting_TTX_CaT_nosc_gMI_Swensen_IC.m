% visualize data for trials involving the Prinz database
% of bursting neurons with TTX that do not oscillate
% with modulatory input conductance added

% establish header
pHeader;

%% Introduction
% This code visualizes simulations over increasing modulatory input for Prinz models.
% The models can be found in the Prinz database (Prinz _et al._ 2003). All bursting models
% were selected and simulated in TTX conditions without transient low-threshold calcium
% e.g. $\bar{g}_{NaV} = \bar{g}_{CaT} = 0$. The models were stripped of NaV and CaT currents,
% and those with voltage oscillation amplitudes < 10 mV were simulated using
% Swensen modulatory input conductance (Swensen & Marder 2001). The initial conditions were modified
% so that $V_m = 0~\mathrm{mV}$ and $m_{MI} = 0$.

create_Prinz
data = load('/home/marder/code/pyloric-simulator/data/data_Prinz_bursting_TTX_CaT_nosc_gMI_Swensen_IC.mat')

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
suptitle('all Prinz bursting models w/o NaV or CaT w/ Swensen MI and IC')
prettyFig()

if being_published
  snapnow
  delete(gcf)
end

%% Visualization of Excised Models
% Models from about the top quintile in each mean metric values were replotted.
% The sets corresponding to the sorted mean metrics in the top quintile were
% intersected to find all neuron indices which correspond to those which exhibit
% 'interesting' behavior.

% pick from about the top quintile
idx = 12000:length(burst_freq);
new_index = index(:,idx);
a = intersect(new_index(1,:),new_index(2,:));
b = intersect(a,new_index(3,:));
c = intersect(b,new_index(4,:));
new_index = index(:,c);
idx_plot      = 1:length(new_index);

% visualize color-maps of metrics
figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1500 1000]);
% plot data
ax(1) = subplot(2,2,1); imagesc(idx_plot,gMI,burst_freq(:,new_index(1,:)));
ax(2) = subplot(2,2,2); imagesc(idx_plot,gMI,amplitude(:,new_index(2,:)));
ax(3) = subplot(2,2,3); imagesc(idx_plot,gMI,volt_peaks(:,new_index(3,:)));
ax(4) = subplot(2,2,4); imagesc(idx_plot,gMI,volt_troughs(:,new_index(4,:)));
% add labels etc.
for ii = 1:length(ax)
  xlabel(ax(ii),'neuron index');
  ylabel(ax(ii),'$\bar{g}_{MI} (\mu S/mm^2)$','interpreter','latex');
  set(ax(ii),'YDir','normal');
  C(ii) = colorbar(ax(ii));
end
C(1).Label.String = 'burst frequency (mV)'; caxis(ax(1),[min(min(burst_freq(:,new_index(1,:)))) max(max(burst_freq(:,new_index(1,:))))]);
C(2).Label.String = 'amplitude (mV)'; caxis(ax(2),[min(min(amplitude(:,new_index(2,:)))) max(max(amplitude(:,new_index(2,:))))]);
C(3).Label.String = 'volt peaks (mV)'; caxis(ax(3),[min(min(volt_peaks(:,new_index(3,:)))) max(max(volt_peaks(:,new_index(3,:))))]);
C(4).Label.String = 'volt troughs (mV)'; caxis(ax(4),[min(min(volt_troughs(:,new_index(4,:)))) max(max(volt_troughs(:,new_index(4,:))))]);
suptitle('excised Prinz bursting models w/o NaV or CaT w/ Swensen MI & IC')
prettyFig()

if being_published
  snapnow
  delete(gcf)
end

% %% Version Info
% % The file that generated this document is called:
% % pFooter;
