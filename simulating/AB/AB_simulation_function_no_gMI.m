function [cost, volt_peaks, volt_troughs] = AB_simulation_function_no_gMI(x)
  % get the burst-period and the duty-cycle and compute the cost
  % preamble
  transient_length      = 0.5;
  weights               = [1 1 1];

  % specify targets
  target_volt_peaks     = -40;
  target_volt_troughs   = -50;

  % initialize output
  cost                  = 0;

  time                  = x.dt:x.dt:x.t_end;
  transient             = floor(transient_length * length(time));

  x.reset;
  % run the simulation
  [V,Ca]              = x.integrate;
  V                   = V(transient:end);
  Ca                  = Ca(transient:end,:);
  % get the waveform characteristics of neuron
  volt_peaks      = max(V);
  volt_troughs    = min(V);
  % get the burst characteristics of neuron
  burst_freq      = getFrequency(x.t_end,V);

  % compute mean-square cost
  this_peak_cost      = weights(1)*std_err(volt_peaks,target_volt_peaks);
  this_trough_cost    = weights(2)*std_err(volt_troughs,target_volt_troughs);
  cost                = cost + this_peak_cost + this_trough_cost;

  % post-processing
  if isnan(cost)
      cost = 8000;
  end
