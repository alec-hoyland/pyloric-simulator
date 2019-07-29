
% set metrics
nModels 			= length(passing);
params 				= params(:,passing);
V 						= V(:,:,:,passing);
burst_freq 		= burst_freq(:,:,passing);
duty_cycle 		= duty_cycle(:,:,passing);
nSpikes 			= nSpikes(:,:,passing);
min_slow_wave	= min_slow_wave(:,:,passing);
max_slow_wave = max_slow_wave(:,:,passing);

gMItrix 			= gMItrix(:,passing);
amplitude     = max_slow_wave - min_slow_wave;

%% Make Figures

time = (20e3 + 0.1 : 0.1 : 20e3 + 5e3)/1e3;
c = linspecer(3);

for ii = 1:nModels
		% create figure
		figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[2000 2000]);
		clear ax;
		for qq = 1:4
			ax(qq)	= subplot(2,2,qq);
		end

		% plot normalized metrics
		hold(ax(1),'on')
		plot(ax(1),gMItrix(:,ii),squeeze(burst_freq(:,1,ii)),'-o','Color',c(1,:));
		plot(ax(1),gMItrix(:,ii),squeeze(burst_freq(:,2,ii)),'-o','Color',c(2,:));
		plot(ax(1),gMItrix(:,ii),squeeze(burst_freq(:,3,ii)),'-o','Color',c(3,:));
		ylabel(ax(1),'frequency (Hz)')
		ylim(ax(1),[min(vectorise(burst_freq))*0.9 max(vectorise(burst_freq))*1.1])

		hold(ax(2),'on')
		plot(ax(2),gMItrix(:,ii),squeeze(duty_cycle(:,1,ii)),'-o','Color',c(1,:));
		plot(ax(2),gMItrix(:,ii),squeeze(duty_cycle(:,2,ii)),'-o','Color',c(2,:));
		plot(ax(2),gMItrix(:,ii),squeeze(duty_cycle(:,3,ii)),'-o','Color',c(3,:));
		ylabel(ax(2),'duty cycle')
		ylim(ax(2),[0 1])

		hold(ax(3),'on')
		plot(ax(3),gMItrix(:,ii),squeeze(nSpikes(:,1,ii)),'-o','Color',c(1,:));
		plot(ax(3),gMItrix(:,ii),squeeze(nSpikes(:,2,ii)),'-o','Color',c(2,:));
		plot(ax(3),gMItrix(:,ii),squeeze(nSpikes(:,3,ii)),'-o','Color',c(3,:));
		ylabel(ax(3),'spikes per burst')
		ylim(ax(3),[min(vectorise(nSpikes))*0.9 max(vectorise(nSpikes))*1.1])

		hold(ax(4),'on')
		plot(ax(4),gMItrix(:,ii),squeeze(amplitude(:,1,ii)),'-o','Color',c(1,:));
		plot(ax(4),gMItrix(:,ii),squeeze(amplitude(:,2,ii)),'-o','Color',c(2,:));
		plot(ax(4),gMItrix(:,ii),squeeze(amplitude(:,3,ii)),'-o','Color',c(3,:));
		ylabel(ax(4),'amplitude (mV)')
		ylim(ax(4),[min(vectorise(amplitude))-1 max(vectorise(amplitude))+1])

		for qq = 1:4
			xlim(ax(qq), [-0.1*max(gMItrix(:,ii)) 1.1*max(gMItrix(:,ii))]);
		end

		xlabel(ax(3), 'g_{MI} (\muS/mm^2)')
		xlabel(ax(4), 'g_{MI} (\muS/mm^2)')

		% tightfig();
		prettyFig('fs',30,'plw',6);
		legend(ax(1),{'AB-PD','LP','PY'})

		% create figure
		figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[2000 2000]);
		clear ax;

		% plot voltage traces
		for qq = 1:6
			ax(qq) = subplot(3,2,qq);
			hold(ax(qq),'on')
		end

		plot(ax(1),time,squeeze(V(:,1,1,ii)),'Color',c(1,:));
		plot(ax(2),time,squeeze(V(:,1,2,ii)),'Color',c(1,:));
		plot(ax(3),time,squeeze(V(:,2,1,ii)),'Color',c(2,:));
		plot(ax(4),time,squeeze(V(:,2,2,ii)),'Color',c(2,:));
		plot(ax(5),time,squeeze(V(:,3,1,ii)),'Color',c(3,:));
		plot(ax(6),time,squeeze(V(:,3,2,ii)),'Color',c(3,:));

		% get filtered traces
		for qq = 1:2
			[~, ~, Vf(:,:,qq)] = findSlowWaveStats(0.1,squeeze(V(:,:,qq,ii)));
		end

		plot(ax(1),time,squeeze(Vf(:,1,1)),'k');
		plot(ax(2),time,squeeze(Vf(:,1,2)),'k');
		plot(ax(3),time,squeeze(Vf(:,2,1)),'k');
		plot(ax(4),time,squeeze(Vf(:,2,2)),'k');
		plot(ax(5),time,squeeze(Vf(:,3,1)),'k');
		plot(ax(6),time,squeeze(Vf(:,3,2)),'k');

    title(ax(1),{''; ''; ['ḡ_{MI} = ' num2str(gMItrix(1,ii)) ' μS/mm^2']})
    title(ax(2),{''; ''; ['ḡ_{MI} = ' num2str(oval(gMItrix(end,ii))) ' μS/mm^2']})

    for qq = 1:6
			xlim(ax(qq),[20 25]);
      ylim(ax(qq),[-80 55]);
		end
		ylabel(ax(1),'AB-PD (mV)')
		ylabel(ax(3),'LP (mV)')
		ylabel(ax(5),'PY (mV)')

		xlabel(ax(5),'time (s)')
		xlabel(ax(6),'time (s)')

		% beautify
		% tightfig();
		prettyFig('fs',30,'plw',1);
		set(ax(1:end-2),'XTickLabel',{});
end
