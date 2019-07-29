% simulate and plot all of these models to demonstrate what they do

create_Prinz  % create a single-compartment model
x.skip_hash_check = true;
time = (x.dt:x.dt:x.t_end) / 1000;

hash = dataHash([dataHash(params) dataHash({x.serialize})]);
data = cache(hash);
if ~isempty(data)
  V = data.V;
  V2 = data.V2;
else
  disp('numerically integrating all parameter sets')
  for ii = 1:length(params)
    textbar(ii,length(params))
    x.reset;  % be paranoid
    % set the conductances
    x.setConductances('Prinz',params(ii,:));
    % simulate the model
    V(:,ii) = x.integrate;
    % add in modulatory current
    x.Prinz.MICurrent.gbar = 0.02;
    V2(:,ii) = x.integrate;
  end
  traces.V = V;
  traces.V2 = V2;
  cache(hash,traces);
end

figure('outerposition',[2 2 2000 2000],'PaperUnits','points','PaperSize',[2000 2000])
subplot(2,1,1); plot(time,V); ylabel('membrane potential (mV)'); title('oscillating AB models with MI')
subplot(2,1,2); plot(time,V2); xlabel('time (s)'); ylabel('membrane potential (mV)')
equalizeAxes(); prettyFig('fs',24)

% plot robustness for the non-CaT case
gMI = linspace(0,0.05,11);
disp('plotting robustness for all parameter sets')
data = plotRobustness(x,params,gMI,true,false);
figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
ax(1) = subplot(2,2,1);
plot(gMI,data.burst_freq)
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('burst frequency (Hz)')
ax(2) = subplot(2,2,2);
plot(gMI,data.volt_peaks - data.volt_troughs)
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage amplitude (mV)')
ax(3) = subplot(2,2,3);
plot(gMI,data.volt_peaks)
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage peaks (mV)')
ax(4) = subplot(2,2,4);
plot(gMI,data.volt_troughs)
xlabel('ḡ_{MI} (μS/mm^2)')
ylabel('voltage troughs (mV)')
suptitle('optimized parameters')
equalizeAxes(ax(3:4)); prettyFig('fs',18)

% plot current traces

% set up xolotl object
create_Prinz
x.skip_hash_check = true;
time = (x.dt:x.dt:x.t_end) / 1000;
gMI = linspace(0,0.05,21);
ctraces = cell(length(gMI),length(params));

% perform simulation
disp('computing current traces')
for qq = 1:length(gMI)
  textbar(qq,length(gMI))
  for ii = 1:length(params)
      textbar(ii,length(params))
      x.reset;  % be paranoid
      % set the conductances
      x.setConductances('Prinz',params(ii,:));
      x.Prinz.MICurrent.gbar = gMI(qq);
      % simulate the model
      [current_trace, V, Ca] = x.getCurrentTrace;
      ctraces{qq,ii} = current_trace;
  end
end

% remove transient
transient = floor(0.5 * length(time));
for ii = 1:numel(ctraces)
  ctraces{ii}{:} = ctraces{ii}{:}(transient:end,:);
end

% separate the currents by index
dep       = [3 7 9];
hyp       = [4 5 6 8];
dep_mat   = zeros(length(dep),length(gMI),length(params));
hyp_mat   = zeros(length(hyp),length(gMI),length(params));
for qq = 1:length(gMI)
  for ii = 1:length(params)
    % sum the currents to get ∫I⋅dt
    csum              = 0.0628 * mean(ctraces{qq,ii}{:});  % nA
    dep_mat(:,qq,ii)  = csum(dep);
    hyp_mat(:,qq,ii)  = csum(hyp);
  end
end

figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[2000 2000]);
c = lines;
ax(1) = subplot(1,2,1); hold on;
ax(2) = subplot(1,2,2); hold on;
for qq = 1:length(params)
  for dep_index = 1:length(dep)
    dep_handle(dep_index) = plot(ax(1),gMI,squeeze(abs(dep_mat(dep_index,:,qq))'),'Color',c(dep_index,:));
  end
  for hyp_index = 1:length(hyp)
    hyp_handle(hyp_index) = plot(ax(2),gMI,squeeze(abs(hyp_mat(hyp_index,:,qq))'),'Color',c(hyp_index+3,:));
  end
end

title(ax(2),'inhibitory currents')
xlabel(ax(2),'ḡ_{MI}^{AB} (\muS/mm^2)')
ylabel(ax(2),'mean current (nA)')
set(ax(2),'YScale','log')
ylim(ax(2),[1e-4,1e4])
legend(hyp_handle,{'A','KCa','Kd','Leak'})
suptitle(num2str(qq))
title(ax(1),'excitatory currents')
xlabel(ax(1),'ḡ_{MI}^{AB} (\muS/mm^2)')
ylabel(ax(1),'mean current (nA)')
ylim(ax(1),[1e-4,1e4])
set(ax(1),'YScale','log')
legend(dep_handle,{'CaS','H','MI'})
prettyFig('fs',18)

% plot the current traces
return

for ii = 1:length(params)
  figure('outerposition',[4 3 1000 3000],'PaperUnits','points','PaperSize',[1000 3000]); hold on
  for qq = 1:length(gMI)
    subplot(length(gMI),1,qq); hold on
    current_matrix = ctraces{qq,ii}{:,:} * 0.0628; % nA
    plot(time,current_matrix);
    ylabel('current (nA)')
    xlabel('time (s)')
    legend('NaV','CaT','CaS','A','KCa','Kd','H','Leak','MI')
  end
  title(num2str(ii));
  equalizeAxes(); prettyFig('fs',24)
  drawnow
end
