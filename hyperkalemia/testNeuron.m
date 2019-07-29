function output = testNeuron(x)

  % preamble
  transient_length      = 0.5;
  time                  = x.dt:x.dt:x.t_end;
  transient             = floor(transient_length * length(time));

  % numerically integrate
  [V,Ca]                = x.integrate;
  V                     = V(transient:end);
  Ca                    = Ca(transient:end);

  % analyze simulation
  burst_metrics         = psychopomp.findBurstMetrics(V,Ca);
  burst_freq            = 1e3 / (x.dt * burst_metrics(1));
  duty_cycle            = burst_metrics(9);
  num_spikes            = burst_metrics(2);

  output = any(burst_freq > 0.5 & burst_freq < 2.5 & duty_cycle > 0.1 & duty_cycle < 0.5 & num_spikes > 3);

end
