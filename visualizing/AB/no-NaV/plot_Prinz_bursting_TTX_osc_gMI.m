% visualize data for trials involving the Prinz database
% of bursting neurons with TTX that oscillate
% with modulatory input conductance added

data = load('data_Prinz_bursting_TTX_osc_gMI.mat')
amplitude = data.volt_peaks - data.volt_troughs;

[~,index] = sort(sum(amplitude));
figure('outerposition',[3 2 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
gMI       = linspace(0,0.05,21);
imagesc(gMI,1:length(amplitude),amplitude(:,index)')
title('Oscillating Models (Amplitude)')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('neuron index')
c = colorbar; c.Label.String = 'Amplitude (mV)';
prettyFig()

[~,index] = sort(sum(data.volt_peaks));
figure('outerposition',[3 2 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
gMI       = linspace(0,0.05,21);
imagesc(gMI,1:length(amplitude),data.volt_peaks(:,index)')
title('Oscillating Models (Volt Peaks)')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('neuron index')
c = colorbar; c.Label.String = 'Peak Height (mV)';
prettyFig()

[~,index] = sort(sum(data.burst_freq));
figure('outerposition',[3 2 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
gMI       = linspace(0,0.05,21);
imagesc(gMI,1:length(amplitude),data.burst_freq(:,index)')
title('Oscillating Models (Frequency)')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('neuron index')
c = colorbar; c.Label.String = 'Oscillation Frequency (Hz)';
prettyFig()
