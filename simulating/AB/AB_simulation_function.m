function [cost, burst_freq, duty_cycle, min_slow_wave, max_slow_wave] = AB_simulation_function(x)
    % get the burst-period and the duty-cycle and compute the cost
    % the peak is the maximum of the trace

    % preamble
    weights               = [100 1e6 1 1];

    % findBurstMetrics parameters
    Ca_peak_similarity          = 0.5;  % default = 0.3
    burst_duration_variability  = 0.5;  % default = 0.1

    % initialize burst-metrics container
    burst_metrics         = zeros(10,1);

    % number of simulations
    gMI                   = linspace(0, 0.2, 6);
    nSims                 = length(gMI);

    % specify targets
    target_duty_cycle     = linspace(0.33,0.33,nSims); % unitless
    target_burst_freq     = linspace(1.00,1.5,nSims); % Hz
    target_slow_wave_min  = linspace(-50,-55,nSims); % mV
    target_slow_wave_max  = linspace(-45,-40,nSims); % mV

    % initialize output
    cost                  = 0;
    cost_components       = zeros(4,1);
    duty_cycle            = NaN(nSims,1);
    burst_freq            = NaN(nSims,1);
    nSpikes               = NaN(nSims,1);
    max_slow_wave         = NaN(nSims,1);
    min_slow_wave         = NaN(nSims,1);

    % cut off transient time
    transient_length      = 0.25;
    time                  = x.dt:x.dt:x.t_end;
    transient             = floor(transient_length * length(time));
    time                  = time(transient:end);

    % perform simulation
    for ii = 1:length(gMI) % for each gMI step
        % set up the xolotl object
        x.reset;
        x.AB.MICurrent.gbar = gMI(ii);

        % run the simulation
        [V,Ca]              = x.integrate;

        % cut off the transient
        V                   = V(transient:end,1);
        Ca                  = Ca(transient:end,1);

        % find burst metrics
        burst_metrics       = psychopomp.findBurstMetrics(V,Ca,Ca_peak_similarity,burst_duration_variability,mean(V));

        % find the burst frequency
        burst_freq(ii)      = 1e3 / (x.dt * burst_metrics(1));

        % find the duty cycle
        duty_cycle(ii)      = sum(V > mean(V)) / length(V);

        % find the peak and trough height
        min_slow_wave(ii)   = min(V);
        max_slow_wave(ii)   = max(V);

        % compute mean-square cost
        cost_components(1)  = weights(1)*std_err(min_slow_wave(ii),target_slow_wave_min(ii));
        cost_components(2)  = weights(2)*std_err(max_slow_wave(ii),target_slow_wave_max(ii));
        cost_components(3)  = weights(3)*std_err(burst_freq(ii),target_burst_freq(ii));
        cost_components(4)  = weights(4)*std_err(duty_cycle(ii),target_duty_cycle(ii));

        NaN_penalty         = isnan(cost_components);
        cost_components(NaN_penalty) = 2000;

        cost                = cost + sum(cost_components);
    end % end the for loop over gMI

    % post-processing
    if isnan(cost)
        cost = 8000;
    end

    % end the simulation


end % end the function
