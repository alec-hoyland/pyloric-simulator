% set static pseudorandom number generation
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1984));

% create the cell
createPrinz

% generate seeds
nTrials               = 100;                      % number of trials
z                     = zoidberg;
seeds                 = z.findNeurons('burster');
new_seed              = NaN(nTrials,8);
ii = 1;
while ii < nTrials + 1
  params              = seeds(:,randi(length(seeds)));
  x.setConductances(1,params);
  [V,Ca]              = x.integrate;
  if testNeuron(x)
    disp(ii)
    new_seed(ii,:)    = params;
    ii = ii + 1;
  end
end
disp('seed list generated')

% perform procrustes simulation
new_params            = NaN(nTrials,8);
for ii = 1:nTrials
  textbar(ii,nTrials)
  % set up procrustes object
  clear p;
  p                   = procrustes;
  p.x                 = x;
  p.parameter_names   = {'Prinz.CaT.gbar','Prinz.CaS.gbar','Prinz.ACurrent.gbar','Prinz.KCa.gbar','Prinz.Kd.gbar','Prinz.HCurrent.gbar','Prinz.Leak.gbar'};
  p.seed              = new_seed(ii,:);
  p.lb                = 0 * p.seed;
  p.ub                = 2000 * ones(length(p.seed),1);
  p.sim_func          = @hyperkalemiaSimulationFunction;

  % fit parameters
  g = p.fit;

  % populate conductance-output
  new_params(ii,:)  = g;
end

% perform psychopomp simulation
% use psychopomp to parallelize and simulate for every new seed
clear p;
p                 = psychopomp;
p.cleanup;
p.n_batches       = 20;
p.x               = x;
params2vary       = {'Prinz.NaV.gbar','Prinz.CaT.gbar','Prinz.CaS.gbar','Prinz.ACurrent.gbar','Prinz.KCa.gbar','Prinz.Kd.gbar','Prinz.HCurrent.gbar','Prinz.Leak.gbar'};
all_params        = new_params';
p.batchify(all_params,params2vary);
% [cost, burst_freq, duty_cycle, num_spikes] = hyperkalemiaSimulationFunction(x)
p.sim_func        = @hyperkalemiaSimulationFunction;
p.simulate;
wait(p.workers)

[all_data,all_params,all_params_idx] = p.gather;
cost              = all_data{1};
bf0               = all_data{2};
dc0               = all_data{3};
ns0               = all_data{4};

% beautify the data
bf0(bf0 < 0)      = 0;
bf_max            = 2.5;
bf_min            = 0.5;
dc_max            = 0.5;
dc_min            = 0.1;
ns_min            = 2;

bf_passing        = all(bf0 > bf_min & bf0 < bf_max);
dc_passing        = all(dc0 > dc_min & dc0 < dc_max);
ns_passing        = all(ns0 > ns_min);
keep_this         = bf_passing & dc_passing & ns_passing;

params_passing    = all_params(:,keep_this);

% visualize
EK                = [-80 -70 -60];
time              = x.dt:x.dt:x.t_end;
for ii = 1:params_passing(1,:)
  figure('outerposition',[4 4 1000 1000],'PaperUnits','points','PaperSize',[1000 1000])
  x.reset;
  x.setConductances('Prinz',params_passing(:,ii));
  V = NaN(length(time),length(EK));
  leg = cell(length(EK),1);
  for qq = 1:length(EK)
    x.Prinz.ACurrent.E    = potassium_reversal(qq);
    x.Prinz.KCa.E         = potassium_reversal(qq);
    x.Prinz.Kd.E          = potassium_reversal(qq);
    V(:,qq)               = x.integrate;
    leg{qq}               = ['EK = ' num2str(EK) ' mV'];
  end
  plot(time,V)
  title(mat2str(params_passing(:,ii)))
  legend(leg)
  xlabel('time (ms)')
  ylabel('membrane potential (mV)')
  ylim([-80,80])
  prettyFig()
  drawnow
end
