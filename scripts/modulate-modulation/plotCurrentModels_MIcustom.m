% futz with modulatory input parameters

create_Prinz  % create a single-compartment model
x.skip_hash_check = true;
time = (x.dt:x.dt:x.t_end) / 1000;

% set custom modulatory input current parameters
Vth       = -55;    % mV
Vwidth    = 5;      % mV
tau_MI    = 6;      % ms
x.Prinz   = rmfield(x.Prinz,'MICurrent');
x.addConductance('Prinz','hoyland/MICurrentCUSTOM',0,-10,0,1,Vth,Vwidth,tau_MI);
x.transpile; x.compile;
disp(x)

% futzed modulatory input parameters
Vth_vec   = [-58 -55 -52];
Vw_vec    = [3 5 8];
tau_MI_vec= [3 6 12];
% permute the combinations from the three parameter vectors
params_MI = allcomb(Vth_vec,Vw_vec,tau_MI_vec);
indices_MI = [5 14 23 11 14 17 13 14 15];

if exist('/home/marder/code/pyloric-simulator/data/data_CurrentModels_MIcustom.mat','file') ~= 2

  % initialize output vectors
  gMI = linspace(0,0.05,21);
  for qq = 1:length(indices_MI)
    textbar(qq,length(indices_MI))
    % transpile and compile the new xolotl object
    x.Prinz.MICurrentCUSTOM.Q_g = params_MI(indices_MI(qq),1);
    x.Prinz.MICurrentCUSTOM.Q_tau_m = params_MI(indices_MI(qq),2);
    x.Prinz.MICurrentCUSTOM.Q_tau_h = params_MI(indices_MI(qq),3);
    output(qq) = plotRobustness(x,params,gMI,false,false);
    close all
  end

  save('/home/marder/code/pyloric-simulator/data/data_CurrentModels_MIcustom.mat','output','gMI','params_MI','params')
  disp('saved in data_CurrentModels_MIcustom.mat')
end


% plot the data
load('/home/marder/code/pyloric-simulator/data/data_CurrentModels_MIcustom.mat')

% plot voltage amplitude
figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[2000 2000]);
ttl   = {['V_{th} = ' num2str(params_MI(indices_MI(1),1)) ' mV'], ...
        ['V_{th} = ' num2str(params_MI(indices_MI(2),1)) ' mV',] ...
        ['V_{th} = ' num2str(params_MI(indices_MI(3),1)) ' mV'], ...
        ['V_w = ' num2str(params_MI(indices_MI(4),2)) ' mV'], ...
        ['V_w = ' num2str(params_MI(indices_MI(5),2)) ' mV'], ...
        ['V_w = ' num2str(params_MI(indices_MI(6),2)) ' mV'], ...
        ['τ_{MI} = ' num2str(params_MI(indices_MI(7),3)) ' ms'], ...
        ['τ_{MI} = ' num2str(params_MI(indices_MI(8),3)) ' ms'], ...
        ['τ_{MI} = ' num2str(params_MI(indices_MI(9),3)) ' ms']};
c = lines;
for ii = 1:9
  ax(ii) = subplot(3,3,ii); hold on;
  plot(ax(ii),gMI,output(ii).volt_peaks' - output(ii).volt_troughs');
end
for ii = 1:9
  title(ax(ii),ttl{ii})
  xlabel(ax(ii),'ḡ_{MI} (μS/mm^2)')
  ylabel(ax(ii),'amplitude (mV)')
end
equalizeAxes(); prettyFig('fs',18)

% plot voltage amplitude
figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[2000 2000]);
c = lines;
for ii = 1:9
  ax(ii) = subplot(3,3,ii); hold on;
  plot(ax(ii),gMI,output((ii)).burst_freq');
end
for ii = 1:9
  title(ax(ii),ttl{ii})
  xlabel(ax(ii),'ḡ_{MI} (μS/mm^2)')
  ylabel(ax(ii),'frequency (mV)')
end
equalizeAxes(); prettyFig('fs',18)

% plot voltage peaks
figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[2000 2000]);
c = lines;
for ii = 1:9
  ax(ii) = subplot(3,3,ii); hold on;
  plot(ax(ii),gMI,output((ii)).volt_peaks');
end
for ii = 1:9
  title(ax(ii),ttl{ii})
  xlabel(ax(ii),'ḡ_{MI} (μS/mm^2)')
  ylabel(ax(ii),'peaks (mV)')
end
equalizeAxes(); prettyFig('fs',18)

% plot voltage amplitude
figure('outerposition',[3 3 1000 1000],'PaperUnits','points','PaperSize',[2000 2000]);
c = lines;
for ii = 1:9
  ax(ii) = subplot(3,3,ii); hold on;
  plot(ax(ii),gMI,output((ii)).volt_troughs');
end
for ii = 1:9
  title(ax(ii),ttl{ii})
  xlabel(ax(ii),'ḡ_{MI} (μS/mm^2)')
  ylabel(ax(ii),'troughs (mV)')
end
equalizeAxes(); prettyFig('fs',18)
