function [cost, burst_freq, duty_cycle, num_spikes] = hyperkalemiaSimulationFunction(x)

  % preamble
  transient_length      = 0.5;
  weights               = [1 1 1];
  time                  = x.dt:x.dt:x.t_end;
  transient             = floor(transient_length * length(time));
  potassium_reversal    = [-80 -70 -60];

  % specify targets
  target_duty_cycle     = 0.2;  % unitless
  target_burst_freq     = 1.0;  % Hz
  target_num_spikes     = 4;

  % initialize outputs
  cost                  = 0;
  burst_freq            = NaN*potassium_reversal;
  duty_cycle            = NaN*potassium_reversal;
  num_spikes            = NaN*potassium_reversal;

  % perform simulation
  for ii = 1:length(potassium_reversal)
    x.reset;

    % set potassium reversal potential
    x.Prinz.ACurrent.E    = potassium_reversal(ii);
    x.Prinz.KCa.E         = potassium_reversal(ii);
    x.Prinz.Kd.E          = potassium_reversal(ii);

    % numerically integrate
    [V,Ca]                = x.integrate;
    V                     = V(transient:end);
    Ca                    = Ca(transient:end);

    % analyze simulation
    burst_metrics         = psychopomp.findBurstMetrics(V,Ca);
    burst_freq(ii)        = 1e3 / (x.dt * burst_metrics(1));
    duty_cycle(ii)        = burst_metrics(9);
    num_spikes(ii)        = burst_metrics(2);

    % compute cost
    this_duty_cost      = weights(1)*std_err(duty_cycle(ii),target_duty_cycle);
    this_freq_cost      = weights(2)*std_err(burst_freq(ii),target_burst_freq);
    this_spike_cost     = weights(3)*std_err(num_spikes(ii),target_num_spikes);
    cost                = cost + this_duty_cost + this_freq_cost + this_spike_cost;
  end
end
