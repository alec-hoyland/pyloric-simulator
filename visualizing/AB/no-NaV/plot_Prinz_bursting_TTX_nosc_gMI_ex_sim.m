% visualize data for trials involving the Prinz database
% of bursting neurons with TTX that do not oscillate
% with modulatory input conductance added

create_Prinz
data = load('data_Prinz_bursting_TTX_nosc_gMI_ex_sim.mat')

% clean the data
keep_this = all(data.burst_freq < 3);
burst_freq = data.burst_freq(:,keep_this);
volt_peaks = data.volt_peaks(:,keep_this);
volt_troughs = data.volt_troughs(:,keep_this);
amplitude = volt_peaks - volt_troughs;
params = data.params(:,keep_this);
gMI = linspace(0,0.05,21);
idx_plot = 1:length(burst_freq);

% visualize burst frequency
index     = zeros(4,length(burst_freq));
[~,index(1,:)] = sort(mean(burst_freq));
figure
imagesc(idx_plot,gMI,burst_freq(:,index(1,:)))
title('burst frequency')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
colorbar
% visualize volt peaks
[~,index(2,:)] = sort(mean(volt_peaks));
figure
imagesc(idx_plot,gMI,volt_peaks(:,index(2,:)))
title('volt peaks')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
colorbar
% visualize volt troughs
[~,index(3,:)] = sort(mean(volt_troughs));
figure
imagesc(idx_plot,gMI,volt_troughs(:,index(3,:)))
title('volt troughs')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
colorbar
% visualize volt amplitude
[~,index(4,:)] = sort(mean(amplitude));
figure
imagesc(idx_plot,gMI,amplitude(:,index(4,:)))
title('volt amplitude')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
colorbar

% find good seeds
a = intersect(index(1,700:1100),index(2,700:1100));
b = intersect(a,index(3,700:1100));
c = intersect(b,index(4,700:1100));

params_passing = data.params(:,c);
return

for ii = 1:length(params_passing)
  textbar(ii,length(params_passing))
  x.setConductances('Prinz',params_passing(:,ii))
  x.reset
  V(:,ii) = x.integrate;
  x.Prinz.MICurrent.gbar = 0.1;
  V2(:,ii) = x.integrate;
end

time  = x.dt * 1:length(V);
figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
for ii = 1:length(data.params(:,index))
  % plot the volt peaks & volt troughs
  subplot(3,3,1)
  plot(data.gMI,volt_peaks(:,ii))
  hold on
  plot(data.gMI,volt_troughs(:,ii));
  hold off
  % plot the amplitude
  subplot(3,3,2)
  plot(data.gMI,amplitude(:,ii))
  % plot the burst frequency
  subplot(3,3,3)
  plot(data.gMI,burst_freq(:,ii))
  % plot the voltage trace
  subplot(3,3,4:6)
  plot(time,V(:,ii))
  % plot the voltage trace with gMI
  subplot(3,3,7:9)
  plot(time,V2(:,ii))
  % plot the volt peaks & volt troughs
  subplot(3,3,1)
  legend('peak','trough')
  xlabel('ḡ_{MI} (μS/mm^2)')
  ylabel('mV')
  title('peak and trough')
  ylim([-50 30])
  % plot the amplitude
  subplot(3,3,2)
  xlabel('ḡ_{MI} (μS/mm^2)')
  ylabel('mV')
  title('amplitude')
  ylim([0 80])
  % plot the burst frequency
  subplot(3,3,3)
  xlabel('ḡ_{MI} (μS/mm^2)')
  ylabel('Hz')
  title('frequency')
  ylim([0 3])
  % plot the voltage trace
  subplot(3,3,4:6)
  ylabel('mV')
  title('sample trace')
  ylim([-60 30])
  % plot the voltage trace with gMI
  subplot(3,3,7:9)
  xlabel('time (ms)')
  ylabel('mV')
  title(['sample trace ḡ_{MI} = ' x.Prinz.MICurrent.gbar ' (μS/mm^2)' ])
  ylim([-60 30])
  % post-processing
  prettyFig()
  drawnow
  filename = ['plot_' mat2str(params_passing(:,ii)) '.png'];
  saveas(gcf,filename)
end
