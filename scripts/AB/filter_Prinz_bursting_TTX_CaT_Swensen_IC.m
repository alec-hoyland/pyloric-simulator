% "It is vowed that the birds are psychopomps lying in wait for the souls of the
% dying, and that they time their eerie cries in unison with the
% sufferer's struggling breath. If they can catch the fleeing soul when it
% leaves the body, they instantly flutter away chittering in daemonic laughter;
% but if they fail, they subside gradually into a disappointed silence."
% -- The Dunwich Horror by H.P. Lovecraft

% simulates and filters neurons from the Prinz database without NaV or CaT
% excitatory perturbation by Swensen modulatory input conductance
% initial conditions are V = 60 mV and m_{MI} = 1

force = true;

% preamble
clear x z p
% create xolotl object
create_Prinz
x.addConductance('Prinz','swensen/MICurrent',0,-22);
x.transpile; x.compile;
x.skip_hash_check = true;

% check to see if data has already been collected
% for the TTX - CaT trial of Prinzian bursting neurons
if ~exist('/home/marder/code/pyloric-simulator/data/data_Prinz_bursting_TTX_CaT.mat','file') | force
  % generate seeds from Prinz database
  z             = zoidberg;
  G             = z.findNeurons('burster')';
  % add modulatory input conductance
  G             = [G zeros(length(G),1)];
  % remove fast sodium conductance
  G(:,1)        = 0;
  % remove transient calcium conductance
  G(:,2)        = 0;
  % use psychopomp to parallelize and simulate for every new seed
  p             = psychopomp;
  p.cleanup;
  p.n_batches   = 20;
  p.x           = x;
  params2vary   = {'Prinz.NaV.gbar','Prinz.CaT.gbar','Prinz.CaS.gbar','Prinz.ACurrent.gbar','Prinz.KCa.gbar','Prinz.Kd.gbar','Prinz.HCurrent.gbar','Prinz.Leak.gbar','Prinz.MICurrent.gbar'};
  all_params    = G';
  p.batchify(all_params,params2vary);
  p.sim_func    = @AB_simulation_function_no_gMI;
  p.simulate(1);
  wait(p.workers)
  % run the psychopomp simulation
  [all_data, all_params] = p.gather;
  cost          = all_data{1};
  volt_peaks    = all_data{2};
  volt_troughs  = all_data{3};
  params        = all_params;
  % save data
  save('data_Prinz_bursting_TTX_CaT.mat','volt_peaks','volt_troughs','params')
  disp('saved in data_Prinz_bursting_TTX_CaT.mat')
else
  % load data
  load('/home/marder/code/pyloric-simulator/data/data_Prinz_bursting_TTX_CaT.mat')
  disp('loaded data_Prinz_bursting_TTX_CaT.mat')
end

% check to see if non-oscillating (quiescent) data have been collected
if ~exist('/home/marder/code/pyloric-simulator/data/data_Prinz_bursting_TTX_CaT_nosc.mat','file') | force
  % find passing conductances
  amplitude         = volt_peaks - volt_troughs;
  keep_this         = amplitude > 10;

  params_passing    = params(:,keep_this);
  peaks_passing     = volt_peaks(keep_this);
  troughs_passing   = volt_troughs(keep_this);
  amps_passing      = amplitude(keep_this);

  params_not_passing    = params(:,~keep_this);
  peaks_not_passing     = volt_peaks(~keep_this);
  troughs_not_passing   = volt_troughs(~keep_this);
  amps_not_passing      = amplitude(~keep_this);

  save('data_Prinz_bursting_TTX_CaT_osc.mat','params_passing','peaks_passing','troughs_passing','amps_passing')
  save('data_Prinz_bursting_TTX_CaT_nosc.mat','params_not_passing','peaks_not_passing','troughs_not_passing','amps_not_passing')
  disp('saved in data_Prinz_bursting_TTX_CaT_osc.mat')
  disp('saved in data_Prinz_bursting_TTX_CaT_nosc.mat')
else
  % find the best range for gMI
  load('/home/marder/code/pyloric-simulator/data/data_Prinz_bursting_TTX_CaT_nosc.mat')
  disp('loaded data_Prinz_bursting_TTX_CaT_nosc.mat')
end

if ~exist('/home/marder/code/pyloric-simulator/data/data_Prinz_bursting_TTX_CaT_nosc_gMI_Swensen_IC.mat','file') | force
  % use psychopomp to parallelize and simulate for every failing seed
  p             = psychopomp;
  p.cleanup;
  p.n_batches   = 20;
  p.x           = x;
  params2vary   = {'Prinz.NaV.gbar','Prinz.CaT.gbar','Prinz.CaS.gbar','Prinz.ACurrent.gbar','Prinz.KCa.gbar','Prinz.Kd.gbar','Prinz.HCurrent.gbar','Prinz.Leak.gbar','Prinz.MICurrent.gbar'};
  all_params    = params_not_passing;
  p.batchify(all_params,params2vary);
  p.sim_func    = @AB_simulation_function_IC;
  p.simulate(1);
  wait(p.workers)
  % run psychopomp simulation
  [all_data, all_params] = p.gather;
  cost          = all_data{1};
  volt_peaks    = all_data{2};
  volt_troughs  = all_data{3};
  burst_freq    = all_data{4};
  IMI           = all_data{5};
  params        = all_params;
  % save data
  save('/home/marder/code/pyloric-simulator/data/data_Prinz_bursting_TTX_CaT_nosc_gMI_Swensen_IC.mat','volt_peaks','volt_troughs','burst_freq','IMI','params')
  disp('saved in data_Prinz_bursting_TTX_CaT_nosc_gMI_Swensen.mat')
else
  disp('DONE!!!')
end
