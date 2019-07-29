% visualize data for trials involving the Prinz database
% of bursting neurons with TTX that do not oscillate
% with modulatory input conductance added

pHeader;

%% Introduction
% The data were obtained from |data_Prinz_bursting_TTX_CaT_nosc_gMI.mat|. All single-compartment
% neurons from the Prinz database (Prinz _et al._ 2003) were simulated without NaV or CaT, and separated into
% strongly oscillating and non-oscillating/weakly-oscillating categories. Non-oscillators were
% simulated with modulatory input (Sharp _et al._ 1993).

% Data were discriminated for the conditions $ -60 < V_{peaks} < 0$ mV and $ -60 V_{troughs} < -30$ mV,
% where the peak voltage is the maximum of the voltage trace after the transient, and the trough
% is the minimum.

create_Prinz
data = load('data_Prinz_bursting_TTX_CaT_nosc_gMI.mat')

% clean the data
keep_this     = all((data.burst_freq < 3) & (data.volt_peaks > -60) & (data.volt_peaks < 0) & (data.volt_troughs > -60) & (data.volt_troughs < -30));
burst_freq    = data.burst_freq(:,keep_this);
volt_peaks    = data.volt_peaks(:,keep_this);
volt_troughs  = data.volt_troughs(:,keep_this);
amplitude     = volt_peaks - volt_troughs;
params        = data.params(:,keep_this);

% Since the Sharp current has a strong basin of activation (cf. IV curve), the maximal
% modulatory input conductance is $0.05 ~ \mu S / mm^2$. 

gMI           = linspace(0,0.05,21);
idx_plot      = 1:length(burst_freq);

% visualize burst frequency
index     = zeros(4,length(burst_freq));
[~,index(1,:)] = sort(mean(burst_freq));
figure
imagesc(idx_plot,gMI,burst_freq(:,index(1,:)))
title('burst frequency')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
set(gca,'YDir','normal')
colorbar

% visualize volt peaks
[~,index(2,:)] = sort(mean(volt_peaks));
figure
imagesc(idx_plot,gMI,volt_peaks(:,index(2,:)))
title('volt peaks')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
set(gca,'YDir','normal')
caxis([-60 -20])
colorbar

% visualize volt troughs
[~,index(3,:)] = sort(mean(volt_troughs));
figure
imagesc(idx_plot,gMI,volt_troughs(:,index(3,:)))
title('volt troughs')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
set(gca,'YDir','normal')
caxis([-60 -20])
colorbar

% visualize volt amplitude
[~,index(4,:)] = sort(mean(amplitude));
figure
imagesc(idx_plot,gMI,amplitude(:,index(4,:)))
title('volt amplitude')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
set(gca,'YDir','normal')
caxis([0 30])
colorbar

% filter into three groups
% quiescents are not responsive to modulatory input (threshold at 10 mV)
bool_nosc        = all(amplitude < 10);
amps_nosc        = amplitude(:,bool_nosc);
[~,idx_nosc]     = sort(mean(amps_nosc));
% decreasing oscillators are responsive to MI and decrease with increasing MI
amps_osc_dec     = amplitude(:,~bool_nosc & amplitude(1,:) >= 10);
[~,idx_osc_dec]  = sort(mean(amps_osc_dec));
% increasing oscillators are resonsive to MI and increase with increasing MI
amps_osc_inc     = amplitude(:,~bool_nosc & amplitude(1,:) < 10);
[~,idx_osc_inc]  = sort(mean(amps_osc_inc));

% repeat discrimination for other metrics
peaks_nosc       = volt_peaks(:,bool_nosc);
[~,idx_nosc]     = sort(mean(peaks_nosc));
% decreasing oscillators are responsive to MI and decrease with increasing MI
peaks_osc_dec    = volt_peaks(:,~bool_nosc & amplitude(1,:) >= 10);
[~,idx_osc_dec]  = sort(mean(peaks_osc_dec));
% increasing oscillators are resonsive to MI and increase with increasing MI
peaks_osc_inc    = volt_peaks(:,~bool_nosc & amplitude(1,:) < 10);
[~,idx_osc_inc]  = sort(mean(peaks_osc_inc));

% repeat discrimination for other metrics
troughs_nosc     = volt_troughs(:,bool_nosc);
[~,idx_nosc]     = sort(mean(troughs_nosc));
% decreasing oscillators are responsive to MI and decrease with increasing MI
troughs_osc_dec  = volt_troughs(:,~bool_nosc & amplitude(1,:) >= 10);
[~,idx_osc_dec]  = sort(mean(troughs_osc_dec));
% increasing oscillators are resonsive to MI and increase with increasing MI
troughs_osc_inc  = volt_troughs(:,~bool_nosc & amplitude(1,:) < 10);
[~,idx_osc_inc]  = sort(mean(troughs_osc_inc));

% create heatmap images for the above metrics
figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
subplot(1,3,1)
imagesc(1:length(amps_nosc),gMI,amps_nosc(:,idx_nosc))
title('quiescent')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
set(gca,'YDir','normal')
caxis([0 50])
subplot(1,3,2)
imagesc(1:length(amps_osc_dec),gMI,amps_osc_dec(:,idx_osc_dec))
title('restorative')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
set(gca,'YDir','normal')
caxis([0 50])
subplot(1,3,3)
imagesc(1:length(amps_osc_inc),gMI,amps_osc_inc(:,idx_osc_inc))
title('regenerative')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
set(gca,'YDir','normal')
C = colorbar;
C.Label.String = 'voltage amplitude (mV)';
caxis([0 50])
prettyFig('fs',18)

figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
subplot(1,3,1)
imagesc(1:length(peaks_nosc),gMI,peaks_nosc(:,idx_nosc))
title('quiescent')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
set(gca,'YDir','normal')
subplot(1,3,2)
imagesc(1:length(peaks_osc_dec),gMI,peaks_osc_dec(:,idx_osc_dec))
title('restorative')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
set(gca,'YDir','normal')
subplot(1,3,3)
imagesc(1:length(peaks_osc_inc),gMI,peaks_osc_inc(:,idx_osc_inc))
title('regenerative')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
set(gca,'YDir','normal')
C = colorbar;
C.Label.String = 'voltage peaks (mV)';
caxis([-50 0])
prettyFig('fs',18)

figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
subplot(1,3,1)
imagesc(1:length(troughs_nosc),gMI,troughs_nosc(:,idx_nosc))
title('quiescent')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
set(gca,'YDir','normal')
caxis([-60 -30])
subplot(1,3,2)
imagesc(1:length(troughs_osc_dec),gMI,troughs_osc_dec(:,idx_osc_dec))
title('restorative')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
set(gca,'YDir','normal')
caxis([-60 -30])
subplot(1,3,3)
imagesc(1:length(troughs_osc_inc),gMI,troughs_osc_inc(:,idx_osc_inc))
title('regenerative')
ylabel('ḡ_{MI} (μS/mm^2)')
xlabel('neuron index')
set(gca,'YDir','normal')
C = colorbar;
C.Label.String = 'voltage troughs (mV)';
caxis([-60 -30])
prettyFig('fs',18)

% make plots of amplitude over modulatory input
figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
subplot(3,1,1)
plot(gMI,amps_nosc)
title('quiescent amplitude')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage amplitude (mV)')
subplot(3,1,2)
plot(gMI,amps_osc_dec)
title('restorative amplitude')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage amplitude (mV)')
subplot(3,1,3)
plot(gMI,amps_osc_inc)
title('regenerative amplitude')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage amplitude (mV)')
equalizeAxes()
prettyFig('fs',18)

% make plots of peaks over modulatory input
figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
subplot(3,1,1)
plot(gMI,peaks_nosc)
title('quiescent peaks')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage peaks (mV)')
subplot(3,1,2)
plot(gMI,peaks_osc_dec)
title('restorative peaks')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage peaks (mV)')
subplot(3,1,3)
plot(gMI,peaks_osc_inc)
title('regenerative peaks')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage peaks (mV)')
equalizeAxes()
prettyFig('fs',18)

% make plots of troughs over modulatory input
figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
subplot(3,1,1)
plot(gMI,troughs_nosc)
title('quiescent troughs')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage troughs (mV)')
subplot(3,1,2)
plot(gMI,troughs_osc_dec)
title('restorative troughs')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage troughs (mV)')
subplot(3,1,3)
plot(gMI,troughs_osc_inc)
title('regenerative troughs')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage troughs (mV)')
equalizeAxes()
prettyFig('fs',18)

%% plot in a 3x3 grid
clear ax
figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])

ax(1) = subplot(3,3,1);
plot(gMI,amps_nosc)
title('quiescent amplitude')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage amplitude (mV)')
ax(2) = subplot(3,3,2);
plot(gMI,amps_osc_dec)
title('restorative amplitude')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage amplitude (mV)')
ax(3) = subplot(3,3,3);
plot(gMI,amps_osc_inc)
title('regenerative amplitude')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage amplitude (mV)')
equalizeAxes(ax(1:3))

ax(4) = subplot(3,3,4);
plot(gMI,peaks_nosc)
title('quiescent peaks')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage peaks (mV)')
ax(5) = subplot(3,3,5);
plot(gMI,peaks_osc_dec)
title('restorative peaks')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage peaks (mV)')
ax(6) = subplot(3,3,6);
plot(gMI,peaks_osc_inc)
title('regenerative peaks')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage peaks (mV)')
equalizeAxes(ax(4:6));

ax(7) = subplot(3,3,7);
plot(gMI,troughs_nosc)
title('quiescent troughs')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage troughs (mV)')
ax(8) = subplot(3,3,8);
plot(gMI,troughs_osc_dec)
title('restorative troughs')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage troughs (mV)')
ax(9) = subplot(3,3,9);
plot(gMI,troughs_osc_inc)
title('regenerative troughs')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage troughs (mV)')
equalizeAxes(ax(7:9))

prettyFig('fs',18)

% simulate neurons from each classification
return
% quiescents are not responsive to modulatory input (threshold at 10 mV)
bool_nosc          = all(amplitude < 10);
params_nosc        = params(:,bool_nosc);
% decreasing oscillators are responsive to MI and decrease with increasing MI
params_osc_dec     = params(:,~bool_nosc & amplitude(1,:) >= 10);
% increasing oscillators are resonsive to MI and increase with increasing MI
params_osc_inc     = params(:,~bool_nosc & amplitude(1,:) < 10);
% generate pseudorandom parameter sets
rand_nosc          = randi(size(params_nosc,2));
rand_osc_dec       = randi(size(params_osc_dec,2));
rand_osc_inc       = randi(size(params_osc_inc,2));
% simulate the non-oscillating models
MIrange            = linspace(0,0.05,6);
V_nosc             = NaN(round(x.t_end/x.dt),3);
x.setConductances('Prinz',params_nosc(:,rand_nosc));
for ii = 1:length(MIrange)
  textbar(ii,length(MIrange))
  x.Prinz.MICurrent.gbar = MIrange(ii);
  V_nosc(:,ii)     = x.integrate;
end
% simulate the restorative models
x.setConductances('Prinz',params_osc_dec(:,rand_osc_dec));
V_osc_dec          = NaN(round(x.t_end/x.dt),3);
for ii = 1:length(MIrange)
  textbar(ii,length(MIrange))
  x.Prinz.MICurrent.gbar = MIrange(ii);
  V_osc_dec(:,ii)  = x.integrate;
end
% simulate the regenerative models
x.setConductances('Prinz',params_osc_inc(:,rand_osc_inc));
V_osc_inc          = NaN(round(x.t_end/x.dt),3);
for ii = 1:length(MIrange)
  textbar(ii,length(MIrange))
  x.Prinz.MICurrent.gbar = MIrange(ii);
  V_osc_inc(:,ii)  = x.integrate;
end

% plot the simulations
figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
Vplot = cell(3,1);
Vplot{1} = V_nosc; Vplot{2} = V_osc_dec; Vplot{3} = V_osc_inc;
time = x.dt*(1:length(V_nosc));
for qq = 1:3
  for ii = 1:length(MIrange)
    subplot_index = 3*(ii - 1) + qq;
    subplot(length(MIrange),3,subplot_index)
    plot(time,Vplot{qq}(:,ii))
  end
end
equalizeAxes()
prettyFig('fs',18)

% find good seeds
a = intersect(index(1,600:end),index(2,600:end));
b = intersect(a,index(3,600:end));
c = intersect(b,index(4,600:end));

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
  prettyFig('fs',18)
  drawnow
  filename = ['plot_' mat2str(params_passing(:,ii)) '.png'];
  saveas(gcf,filename)
end
