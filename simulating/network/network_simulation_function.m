function [cost, metrics, V, V_MI, Ca, Ca_MI] = network_simulation_function(x,posthoc)

if nargin < 2
  posthoc = false;
end

% get the burst-period and the duty-cycle and compute the cost
% this is a two-step process
% first the simulation runs for the case x.AB.MICurrent.gbar = 0
% then this value is used to compute the normalized change in metrics for the modulated case

cost                  = 0;
target_burst_freq     = 1.5;
target_duty_cycle     = 1.0;
target_slow_wave_min  = -5;           % mV
target_slow_wave_max  = 5;            % mV
weights               = [5e3 1 1 1e2];

% initialize outputs
nSims                 = 6;
metrics               = NaN(24,nSims);

% create vector of gMI values from each compartment
compartments = x.find('compartment');
gMI_names = x.find('*MICurrent.gbar');
gMI = x.get(gMI_names);
% create vector of linearly spaced gMI values based on the first compartment's maximum
gMI_vec = linspace(0,gMI(1),nSims);

for ii = 1:nSims
  % set gMI to value from vector
  x.set(gMI_names,gMI_vec(ii));
  x.reset;

  % simulate no gMI case
  [c0, ~, metrics(:,ii), V0, Ca0] = isPyloric(x,posthoc);
  if ii == 1
    V = V0;
    Ca = Ca0;
  elseif ii == nSims
    V_MI = V0;
    Ca_MI = Ca0;
  end
  if c0 > 1000;
    cost = c0 * 3 * nSims;
    if ~posthoc
      return
    end
  end

end

% check ratios
ratios = metrics(:,end) ./ metrics(:,1);

% compute burst frequency cost
for ii = 7:9
  cost = cost + weights(1)*std_err(1/ratios(ii),target_burst_freq);
end

% compute duty-cycle cost
for ii = 10:12
  cost = cost + weights(2)*std_err(ratios(ii),target_duty_cycle);
end

% do the following tests for only cells with modulatory input
compsCurrent = [];
for ii = 1:length(compartments)
  if find(strcmp(x.(compartments{ii}).Children, 'MICurrent'))
    compsCurrent(end+1) = ii;
  end
end

% compute slow wave minimum cost
for ii = compsCurrent + 18
  cost = cost + weights(3)*std_err(metrics(ii,end) - metrics(ii,1) - target_slow_wave_min, 0)/target_slow_wave_min^2;
end

% compute slow wave maximum cost
for ii = compsCurrent + 21
  cost = cost + weights(4)*std_err(metrics(ii,end) - metrics(ii,1) - target_slow_wave_max, 0)/target_slow_wave_max^2;
end

% determine final cost
% cost = cost + c1 + c2;
