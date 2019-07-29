function [cost, metrics, V, V_MI, Ca, Ca_MI] = network_simulation_function_ABPD_LP(x)

% get the burst-period and the duty-cycle and compute the cost
% this is a two-step process
% first the simulation runs for the case x.AB.MICurrent.gbar = 0
% then this value is used to compute the normalized change in metrics for the modulated case


% initialize outputs
metrics               = NaN(24,4);
cost                  = NaN(4,1);

x.reset;
x.AB.MICurrent.gbar = 0;
x.AB.MICurrent.gbar = 0;
[cost(1), ~, metrics(:,1)] = isPyloric(x);

if cost(1) < 1e4
    cost(1) = 1e6;
end

x.reset;
x.AB.MICurrent.gbar = 1;
x.AB.MICurrent.gbar = 0;
[cost(2), ~, metrics(:,2)] = isPyloric(x);

if cost(2) < 1e4
    cost(2) = 1e6;
end

x.reset;
x.AB.MICurrent.gbar = 0;
x.AB.MICurrent.gbar = 1;
[cost(3), ~, metrics(:,3)] = isPyloric(x);

if cost(3) < 1e4
    cost(3) = 1e6;
end

x.reset;
x.AB.MICurrent.gbar = 1;
x.AB.MICurrent.gbar = 1;
[cost(4), ~, metrics(:,4)] = isPyloric(x);

if cost(4) > 500
    cost = cost(4);
else
  cost(4) = 0;
end

cost = sum(cost);
