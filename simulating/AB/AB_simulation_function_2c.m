function [cost, metrics1, metrics2] = AB_simulation_function_2c(x)

% get the burst-period and the duty-cycle and compute the cost
% this is a two-step process
% first the simulation runs for the case x.AB.MICurrent.gbar = 0
% then this value is used to compute the normalized change in metrics for the modulated case

cost                  = 0;
target_burst_freq     = 1.5;
target_duty_cycle     = 1.0;
target_slow_wave_min  = -5; % mV
target_slow_wave_max  = 5; % mV
weights               = [1e3 1 1 1e2];

metrics1              = NaN(4,1);
metrics2              = NaN(4,1);

gMI = x.get(x.find('*MICurrent.gbar'));

% set gMI to zero
x.set(x.find('*MICurrent.gbar'),0);
% simulate no gMI case
[c1, ~, metrics1(1), metrics1(2), metrics1(3), metrics1(4)] = isPacemaker(x);
if c1 > 100
  cost = c1 * 3;
  return
end

% set gMI to nonzero
x.set(x.find('*MICurrent.gbar'),gMI(:))
% simulate gMI case
[c2, ~, metrics2(1), metrics2(2), metrics2(3), metrics2(4)] = isPacemaker(x);
if c2 > 100
  cost = c2 * 3;
  return
end

% compute burst frequency cost
cost = cost + weights(1)*std_err(metrics1(1)/metrics2(1), target_burst_freq);

% compute duty-cycle cost
cost = cost + weights(2)*std_err(metrics2(2)/metrics1(2), target_duty_cycle);

% compute slow wave minimum cost
cost = cost + weights(3)*std_err(metrics2(3) - metrics1(3), target_slow_wave_min);

% compute slow wave maximum cost
cost = cost + weights(4)*std_err(metrics2(4) - metrics1(4), target_slow_wave_max);

% determine final cost
% cost = cost + c1 + c2;
% outputs
metrics1 = [metrics1(1), metrics1(2), metrics1(3), metrics1(4)];
metrics2 = [metrics2(1), metrics2(2), metrics2(3), metrics2(4)];
