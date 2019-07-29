function handles = prinz_visualization_function_AB(handles,x)

if nargin == 0
	% need to make a new figure

	handles.fig = figure('outerposition',[3 3 1000 777],'PaperUnits','points','PaperSize',[1000 777]); hold on

	% plot metrics
	handles.ax(1) = subplot(4,4,1); hold on
	handles.ln(1) = plot(NaN,NaN,'ko-');
	set(gca,'YLim',[1 1.5])
	xlabel('gMI')
	ylabel('norm. burst freq')

	% plot metrics
	handles.ax(2) = subplot(4,4,2); hold on
	handles.ln(2) = plot(NaN,NaN,'ko-');
	set(gca,'YLim',[1 3])
	xlabel('gMI')
	ylabel('norm. duty cycle')

	% plot metrics
	handles.ax(3) = subplot(4,4,3); hold on
	handles.ln(3) = plot(NaN,NaN,'ko-');
	set(gca,'YLim',[1 1.5])
	xlabel('gMI')
	ylabel('norm. spikes')

	% plot metrics
	handles.ax(4) = subplot(4,4,4); hold on
	handles.ln(4) = plot(NaN,NaN,'ko-');
	set(gca,'YLim',[0 6])
	xlabel('gMI')
	ylabel('amplitude (mV)')

	% plot traces
	handles.ax(5) = subplot(4,4,5:6); hold on
	handles.ln(5) = plot(NaN,NaN,'k-');
	set(gca,'YLim',[-80 60])
	% xlabel('time')
	ylabel('V_{AB} (mV)')
	title('No g_{MI}')

	% plot traces
	handles.ax(6) = subplot(4,4,7:8); hold on
	handles.ln(6) = plot(NaN,NaN,'k-');
	set(gca,'YLim',[-80 60])
	% xlabel('time')
	% ylabel('V_{AB} (mV)')
	title('g_{MI}')

	% plot traces
	handles.ax(7) = subplot(4,4,9:10); hold on
	handles.ln(7) = plot(NaN,NaN,'k-');
	set(gca,'YLim',[-80 60])
	xlabel('time (s)')
	ylabel('V_{LP} (mV)')
	% title('No g_{MI}')

	% plot traces
	handles.ax(8) = subplot(4,4,11:12); hold on
	handles.ln(8) = plot(NaN,NaN,'k-');
	set(gca,'YLim',[-80 60])
	% xlabel('time')
	% ylabel('V_{LP} (mV)')
	% title('g_{MI}')

	% plot traces
	handles.ax(9) = subplot(4,4,13:14); hold on
	handles.ln(9) = plot(NaN,NaN,'k-');
	set(gca,'YLim',[-80 60])
	xlabel('time (s)')
	ylabel('V_{PY} (mV)')
	% title('No g_{MI}')

	% plot traces
	handles.ax(10) = subplot(4,4,15:16); hold on
	handles.ln(10) = plot(NaN,NaN,'k-');
	set(gca,'YLim',[-80 60])
	xlabel('time')
	% ylabel('V_{PY} (mV)')
	% title('g_{MI}')

	prettyFig();
else
	% collect data
	[cost, burst_freq, duty_cycle, nSpikes, min_slow_wave, max_slow_wave, Vtrace] = network_simulation_function_AB(x);
	% reshape to gMI × nCells
	burst_freq    = reshape(burst_freq,2,3);
	duty_cycle    = reshape(duty_cycle,2,3);
	nSpikes       = reshape(nSpikes,2,3);
	amplitude     = max_slow_wave - min_slow_wave;

	% normalize
	norm_duty     = duty_cycle ./ duty_cycle(1,:);
	norm_freq     = burst_freq ./ burst_freq(1,:);
	norm_spks     = nSpikes ./ nSpikes(1,:);
	norm_amps			= amplitude - amplitude(1);
	% delta_amp     = amplitude(2,:) - amplitude(1,:);

	% update metrics
	handles.ln(1).XData = [-0.2 1.2];
	handles.ln(1).YData = norm_freq(:,1);

	handles.ln(2).XData = [-0.2 1.2];
	handles.ln(2).YData = norm_duty(:,1);

	handles.ln(3).XData = [-0.2 1.2];
	handles.ln(3).YData = norm_spks(:,1);

	handles.ln(4).XData = [-0.2 1.2];
	handles.ln(4).YData = norm_amps(:);

	% update traces
	time = (1:length(Vtrace{1}))*x.dt/1e3;
	set(handles.ax(5:end),'XLim',[max(time)-5 max(time)])

	handles.ln(5).XData = time;
	handles.ln(5).YData = Vtrace{1}(:,1);

	handles.ln(7).XData = time(:);
	handles.ln(7).YData = Vtrace{1}(:,2);

	handles.ln(9).XData = time(:);
	handles.ln(9).YData = Vtrace{1}(:,3);

	handles.ln(6).XData = time(:);
	handles.ln(6).YData = Vtrace{2}(:,1);

	handles.ln(8).XData = time(:);
	handles.ln(8).YData = Vtrace{2}(:,2);

	handles.ln(10).XData = time(:);
	handles.ln(10).YData = Vtrace{2}(:,3);
end
