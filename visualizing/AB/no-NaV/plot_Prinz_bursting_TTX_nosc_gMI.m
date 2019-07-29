% visualize data for trials involving the Prinz database
% of bursting neurons with TTX that do not oscillate
% with modulatory input conductance added

data = load('data_Prinz_bursting_TTX_nosc_gMI.mat')

amplitude = data.volt_peaks - data.volt_troughs;
[~,index] = sort(sum(amplitude));
figure('outerposition',[3 2 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
gMI       = linspace(0,0.05,21);
imagesc(gMI,1:length(amplitude),amplitude(:,index)')
title('Non-Oscillating Models with Modulatory Input')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('neuron index')
c = colorbar; c.Label.String = 'amplitude (mV)';
prettyFig()

figure('outerposition',[3 2 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
errorbar(gMI,mean(amplitude'),sem(amplitude'))
title('Non-Oscillating Models with Modulatory Input')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('amplitude (mV)')
ylim([0 80])
prettyFig()

figure('outerposition',[3 2 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
nonQuiescent = amplitude > 10;
plot_this    = sum(nonQuiescent')/length(nonQuiescent);
plot(gMI,plot_this)
title('Quiescence vs. Modulatory Input')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('fraction non-quiescent')
ylim([0 1])
prettyFig()

% excise and enhance the models with the greatest sensitivity to gMI


figure('outerposition',[3 2 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
gMI       = linspace(0,0.05,21);
imagesc(gMI,1:length(new_amps),new_amps')
title('Non-Oscillating Models with Modulatory Input')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('neuron index')
c = colorbar; c.Label.String = 'amplitude (mV)';
prettyFig()

% do the same for the coarser modulatory input
data = load('data_Prinz_bursting_TTX_nosc_gMI2.mat')
amplitude = data.volt_peaks - data.volt_troughs;
[~,index] = sort(sum(amplitude));
figure('outerposition',[3 2 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
gMI       = linspace(0,0.2,9);
imagesc(gMI,1:length(amplitude),amplitude(:,index)')
title('Non-Oscillating Models with Modulatory Input')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('neuron index')
c = colorbar; c.Label.String = 'amplitude (mV)';
prettyFig()

figure('outerposition',[3 2 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
errorbar(gMI,mean(amplitude'),sem(amplitude'))
title('Non-Oscillating Models with Modulatory Input')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('amplitude (mV)')
ylim([0 80])
prettyFig()

figure('outerposition',[3 2 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
nonQuiescent = amplitude > 10;
plot_this    = sum(nonQuiescent')/length(nonQuiescent);
plot(gMI,plot_this)
title('Quiescence vs. Modulatory Input')
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('fraction non-quiescent')
ylim([0 1])
prettyFig()
