% simulate the prinzian models in
% Nature Neuroscience Volume 7 Number 12 December 2004 by A.A. Prinz, Dirk Bucher, and Eve Marder

force = false;

create_pyloric;

% create maximal conductance matrix
ABcond          = zeros(5,9);
LPcond          = zeros(5,9);   % μS/cm^2
PYcond          = zeros(6,9);

ABcond(1,:)     = [400 2.5 6 50 10 100 0.01 0.00 0];
ABcond(2,:)     = [100 2.5 6 50 5 100 0.01 0.00 0];
ABcond(3,:)     = [200 2.5 4 50 5 50 0.01 0.00 0];
ABcond(4,:)     = [200 5.0 4 40 5 125 0.01 0.00 0];
ABcond(5,:)     = [300 2.5 2 10 5 125 0.01 0.00 0];

LPcond(1,:)     = [100 0 8 40 5 75 0.05 0.02 0];
LPcond(2,:)     = [100 0 6 40 5 50 0.05 0.02 0];
LPcond(3,:)     = [100 0 10 50 5 100 0.00 0.03 0];
LPcond(4,:)     = [100 0 4 20 0 25 0.05 0.03 0];
LPcond(5,:)     = [100 0 6 30 0 50 0.03 0.02 0];

PYcond(1,:)     = [100 2.5 2 50 0 125 0.05 0.01 0];
PYcond(2,:)     = [200 7.5 0 50 0 75 0.05 0.00 0];
PYcond(3,:)     = [200 10 0 50 0 100 0.03 0.00 0];
PYcond(4,:)     = [400 2.5 2 50 0 75 0.05 0.00 0];
PYcond(5,:)     = [500 2.5 2 40 0 125 0.01 0.03 0];
PYcond(6,:)     = [500 2.5 2 40 0 125 0.00 0.02 0];

g_syns          = zeros(6,7);

g_syns(1,:)     = [10 10 100 3 30 1 3];
g_syns(2,:)     = [3 0 0 30 3 3 0];
g_syns(3,:)     = [100 30 0 1 0 3 0];
g_syns(4,:)     = [3 10 100 1 10 3 10];
g_syns(5,:)     = [30 10 30 3 30 1 30];
g_syns(6,:)     = [3 10 100 1 10 3 10];

ABcond          = ABcond * 10;
LPcond          = LPcond * 10;    % μS/mm^2
PYcond          = PYcond * 10;
g_syns          = g_syns * 10;

% perform simulations
x.dt            = 50e-3;
x.t_end         = 20e3;
x.transpile; x.compile;

% build parameter matrix
Nsims           = length(ABcond(:,1)) * length(LPcond(:,1)) * length(PYcond(:,1)) * length(g_syns(:,1));
Nparams         = length(ABcond(1,:)) + length(LPcond(1,:)) + length(PYcond(1,:)) + length(g_syns(1,:));
G               = NaN(Nsims,Nparams);
counter         = 1;
for AB_index = 1:length(ABcond(:,1))
  for LP_index = 1:length(LPcond(:,1))
    for PY_index = 1:length(PYcond(:,1))
      for syndex = 1:length(g_syns(:,1))
        G(counter,:) = [ABcond(AB_index,:) LPcond(LP_index,:) PYcond(PY_index,:) g_syns(syndex,:)];
        counter = counter + 1;
      end
    end
  end
end

if ~exist('data_Prinz_network.mat','file') | force
  % use psychopomp to parallelize and simulate for every new seed
  p             = psychopomp;
  p.cleanup;
  p.n_batches   = 20;
  p.x           = x;
  params2vary   = {'AB.NaV.gbar','AB.CaT.gbar','AB.CaS.gbar','AB.ACurrent.gbar','AB.KCa.gbar','AB.Kd.gbar','AB.HCurrent.gbar','AB.Leak.gbar','AB.MICurrent.gbar', ...
                  'LP.NaV.gbar','LP.CaT.gbar','LP.CaS.gbar','LP.ACurrent.gbar','LP.KCa.gbar','LP.Kd.gbar','LP.HCurrent.gbar','LP.Leak.gbar','LP.MICurrent.gbar', ...
                  'PY.NaV.gbar','PY.CaT.gbar','PY.CaS.gbar','PY.ACurrent.gbar','PY.KCa.gbar','PY.Kd.gbar','PY.HCurrent.gbar','PY.Leak.gbar','PY.MICurrent.gbar', ...
                  'synapses(1).gbar','synapses(2).gbar','synapses(3).gbar','synapses(4).gbar','synapses(5).gbar','synapses(6).gbar','synapses(7).gbar'};
  all_params    = G';
  p.batchify(all_params,params2vary);
  p.sim_func    = @prinz_simulation_function_AB;
  p.simulate(1)
  wait(p.workers);
  % gather the data
  [all_data, all_params] = p.gather;
  cost          = all_data{1};
  burst_freq    = all_data{2};
  duty_cycle    = all_data{3};
  phase_diff    = all_data{4};
  nSpikes       = all_data{5};
  params        = all_params;
	% save the data
  save('/home/marder/code/pyloric-simulator/data/data_Prinz_network.mat','cost','burst_freq','duty_cycle','phase_diff','nSpikes','params');
  disp('saved in data_Prinz_network.mat')
  data = load('/home/marder/code/pyloric-simulator/data/data_Prinz_network.mat')
else
  data = load('/home/marder/code/pyloric-simulator/data/data_Prinz_network.mat')
  disp('loaded data_Prinz_network.mat')
end

% reshape the metrics
gMI 							= linspace(0,2,21);
gMI_tol           = find(gMI <= 0.5);

burst_freq    		= reshape(data.burst_freq,21,3,length(data.burst_freq));
duty_cycle    		= reshape(data.duty_cycle,21,3,length(data.duty_cycle));
nSpikes       		= reshape(data.nSpikes,21,3,length(data.nSpikes));
phase_diff    		= reshape(data.phase_diff,21,3,length(data.phase_diff));
params            = data.params;

% find tolerance for modulatory input maximal conductance for a range of duty cycle
gMI_tol           = find(gMI <= 0.5);
dc0               = squeeze(duty_cycle(gMI_tol,:,:));
bool0             = (dc0 > 0.1) & (dc0 < 0.6);
keep_this         = squeeze(all(all(bool0)));

% look at new metrics for a range of duty cycle
burst_freq        = burst_freq(gMI_tol,:,keep_this);
duty_cycle        = duty_cycle(gMI_tol,:,keep_this);
nSpikes           = nSpikes(gMI_tol,:,keep_this);
phase_diff        = phase_diff(gMI_tol,:,keep_this);
% new parameters
new_params        = params(:,keep_this);

if ~exist('data_Prinz_network_ex_AB.mat','file') | force
  % use psychopomp to parallelize and simulate for every new seed
  p             = psychopomp;
  p.cleanup;
  p.n_batches   = 20;
  p.x           = x;
  params2vary   = {'AB.NaV.gbar','AB.CaT.gbar','AB.CaS.gbar','AB.ACurrent.gbar','AB.KCa.gbar','AB.Kd.gbar','AB.HCurrent.gbar','AB.Leak.gbar','AB.MICurrent.gbar', ...
                  'LP.NaV.gbar','LP.CaT.gbar','LP.CaS.gbar','LP.ACurrent.gbar','LP.KCa.gbar','LP.Kd.gbar','LP.HCurrent.gbar','LP.Leak.gbar','LP.MICurrent.gbar', ...
                  'PY.NaV.gbar','PY.CaT.gbar','PY.CaS.gbar','PY.ACurrent.gbar','PY.KCa.gbar','PY.Kd.gbar','PY.HCurrent.gbar','PY.Leak.gbar','PY.MICurrent.gbar', ...
                  'synapses(1).gbar','synapses(2).gbar','synapses(3).gbar','synapses(4).gbar','synapses(5).gbar','synapses(6).gbar','synapses(7).gbar'};
  all_params    = new_params;
  p.batchify(all_params,params2vary);
  p.sim_func    = @prinz_simulation_function_AB;
  p.simulate(1);
  wait(p.workers)
  % gather the data
  [all_data, all_params] = p.gather;
  cost          = all_data{1};
  burst_freq    = all_data{2};
  duty_cycle    = all_data{3};
  phase_diff    = all_data{4};
  nSpikes       = all_data{5};
  params        = all_params;
  % save the data
  save('data_Prinz_network_ex_AB.mat','cost','burst_freq','duty_cycle','phase_diff','nSpikes','params')
  disp('saved in data_Prinz_network_ex_AB.mat')
else
  data = load('data_Prinz_network_ex_AB.mat')
  disp('loaded data_Prinz_network_ex_AB.mat')
end

if ~exist('data_Prinz_network_ex_LP.mat','file') | force
  % use psychopomp to parallelize and simulate for every new seed
  p             = psychopomp;
  p.cleanup;
  p.n_batches   = 20;
  p.x           = x;
  params2vary   = {'AB.NaV.gbar','AB.CaT.gbar','AB.CaS.gbar','AB.ACurrent.gbar','AB.KCa.gbar','AB.Kd.gbar','AB.HCurrent.gbar','AB.Leak.gbar','AB.MICurrent.gbar', ...
                  'LP.NaV.gbar','LP.CaT.gbar','LP.CaS.gbar','LP.ACurrent.gbar','LP.KCa.gbar','LP.Kd.gbar','LP.HCurrent.gbar','LP.Leak.gbar','LP.MICurrent.gbar', ...
                  'PY.NaV.gbar','PY.CaT.gbar','PY.CaS.gbar','PY.ACurrent.gbar','PY.KCa.gbar','PY.Kd.gbar','PY.HCurrent.gbar','PY.Leak.gbar','PY.MICurrent.gbar', ...
                  'synapses(1).gbar','synapses(2).gbar','synapses(3).gbar','synapses(4).gbar','synapses(5).gbar','synapses(6).gbar','synapses(7).gbar'};
  all_params    = new_params;
  p.batchify(all_params,params2vary);
  p.sim_func    = @prinz_simulation_function_LP;
  p.simulate(1);
  wait(p.workers)
  % gather the data
  [all_data, all_params] = p.gather;
  cost          = all_data{1};
  burst_freq    = all_data{2};
  duty_cycle    = all_data{3};
  phase_diff    = all_data{4};
  nSpikes       = all_data{5};
  params        = all_params;
  % save the data
  save('data_Prinz_network_ex_LP.mat','cost','burst_freq','duty_cycle','phase_diff','nSpikes','params')
  disp('saved in data_Prinz_network_ex_LP.mat')
else
  data = load('data_Prinz_network_ex_LP.mat')
  disp('loaded data_Prinz_network_ex_LP.mat')
end

return

% sample
for qq = 1:15
  textbar(qq,15)
  x.reset;
  for ii = 1:length(params2vary)
    eval(['x.' params2vary{ii} '=' num2str(params(ii,qq)) ';']);
  end
  figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
  V = x.integrate;
  x.AB.MICurrent.gbar = 0.5;
  V2 = x.integrate;
  x.AB.MICurrent.gbar = 1.0;
  V3 = x.integrate;
  subplot(3,1,1); plot(V); legend('AB','LP','PY')
  subplot(3,1,2); plot(V2);
  subplot(3,1,3); plot(V3);
  prettyFig(); drawnow
end
