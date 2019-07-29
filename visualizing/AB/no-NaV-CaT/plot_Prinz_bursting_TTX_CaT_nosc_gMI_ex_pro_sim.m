% visualize data for trials involving the Prinz database
% of bursting neurons with TTX that do not oscillate
% with modulatory input conductance added

create_Prinz
data = load('data_Prinz_bursting_TTX_CaT_nosc_gMI_ex_pro.mat')
params = [zeros(length(data.params),1) data.params];
gMI  = linspace(0,0.05,11);
time = x.dt:x.dt:x.t_end;

for ii = 1:length(params)
  textbar(ii,length(params))

  x.setConductances('Prinz',params(ii,:))
  x.reset
  V = x.integrate; x.reset;
  x.Prinz.MICurrent.gbar = gMI(6);
  V2 = x.integrate; x.reset;
  x.Prinz.MICurrent.gbar = gMI(11);
  V3 = x.integrate; x.reset;
  [cost, volt_peaks, volt_troughs, burst_freq] = AB_simulation_function(x,gMI);

  figure('outerposition',[4 3 1000 3000],'PaperUnits','points','PaperSize',[1000 3000]); hold on

  subplot(4,3,1); hold on
  plot(gMI,burst_freq,'ko-');
  ylabel('frequency (Hz)')
  xlabel('ḡ_{MI}^{AB} (\muS/mm^2)')
  set(gca,'YLim',[0 2])

  subplot(4,3,2); hold on
  plot(gMI,volt_peaks,'ko-');
  ylabel('peak height (mV)')
  xlabel('ḡ_{MI}^{AB} (\muS/mm^2)')
  title(mat2str(params(ii,:)))
  set(gca,'YLim',[-40 20])

  subplot(4,3,3); hold on
  plot(gMI,volt_peaks-volt_troughs,'ko-');
  ylabel('amplitude (mV)')
  xlabel('ḡ_{MI}^{AB} (\muS/mm^2)')
  set(gca,'YLim',[0,60])

  subplot(4,3,4:6); hold on
  plot(time,V,'k');
  % title('ḡ_{MI}^{AB} = 0 (\muS/mm^2)')
  ylabel('V_{AB} (mV)')
  set(gca,'YLim',[-80 70])

  subplot(4,3,7:9); hold on
  plot(time,V2,'k');
  % title('ḡ_{MI}^{AB} = 0.02 (\muS/mm^2)')
  ylabel('V_{AB} (mV)')
  set(gca,'YLim',[-80 70])

  subplot(4,3,10:12); hold on
  plot(time,V3,'k');
  % title('ḡ_{MI}^{AB} = 0.05 (\muS/mm^2)')
  xlabel('time (ms)')
  ylabel('V_{AB} (mV)')
  set(gca,'YLim',[-80 70])

  prettyFig('fs',18)
  drawnow
end


return

% clean the data
keep_this = all(data.burst_freq < 3 & data.volt_peaks > -60 & data.volt_peaks < 0 & data.volt_troughs > -60 & data.volt_troughs < -30);
burst_freq = data.burst_freq(:,keep_this);
volt_peaks = data.volt_peaks(:,keep_this);
volt_troughs = data.volt_troughs(:,keep_this);
amplitude = volt_peaks - volt_troughs;
params = data.params(:,keep_this);
gMI = linspace(0,0.05,21);
idx_plot = 1:length(burst_freq);
