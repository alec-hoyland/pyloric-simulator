function [cost, volt_peaks, volt_troughs, burst_freq, IMI] = AB_simulation_function_IC_zoom(x,gMI)
    % get the burst-period and the duty-cycle and compute the cost
    % the peak is the maximum of the trace

    % preamble
    disp('do')
    % set the simulation time and transient length
    time                  = x.dt:x.dt:x.t_end;
    transient_length      = 0.5;
    transient             = floor(transient_length * length(time));
    weights               = [1 1 0];
    % set default arguments
    if nargin < 2
        gMI               = [linspace(0,0.8,5) linspace(1.0,1.5,21)];    % μS/mm^2
    end
    % declare alias variables
    nSims                 = length(gMI);

    % specify targets
    target_volt_peaks     = linspace(-50,-20,nSims);  % mV
    target_volt_troughs   = linspace(-50,-55,nSims);  % mV
    target_burst_freq     = linspace(0,1.2,nSims);  % Hz

    % initialize output
    cost                  = 0;
    volt_peaks            = NaN*gMI;
    volt_troughs          = NaN*gMI;
    burst_freq            = NaN*gMI;
    IMI                   = NaN*gMI;

    for ii = 1:length(gMI)
        % begin the simulation
        disp(['doing (' num2str(ii) '/' num2str(length(gMI)) ')'])

        % reset xolotl object to default intitial conditions
        x.reset;

        % set initial conditions
        x.Prinz.V = 0; % mV
        x.Prinz.MICurrent.m = 1; % unitless

        % set parameter to vary
        comp = x.compartment_names(1);              % get compartment name
        cond = x.getChannelsInCompartment(1);       % get all conductances in that compartment
        x.(comp{1}).(cond{end}).gbar = gMI(ii);     % this is the MI conductances

        % run the simulation
        [ct,V,Ca]           = x.getCurrentTrace;
        ctrace              = ct{1}(transient:end,:);
        V                   = V(transient:end);
        Ca                  = Ca(transient:end,:);

        % get the waveform characteristics of neuron
        volt_peaks(ii)      = max(V);
        volt_troughs(ii)    = min(V);

        % get the MI characteristics of neuron
        IMI(ii)             = max(ctrace(:,end));

        % get the burst characteristics of neuron
        burst_freq(ii)      = getFrequency(length(V)*x.dt,V);

        % compute mean-square cost
        this_peak_cost      = weights(1)*std_err(volt_peaks(ii),target_volt_peaks(ii));
        this_trough_cost    = weights(2)*std_err(volt_troughs(ii),target_volt_troughs(ii));
        this_freq_cost      = weights(3)*std_err(burst_freq(ii),target_burst_freq(ii));
        cost                = cost + this_peak_cost + this_trough_cost + this_freq_cost;

    end % end the for loop over gMI

    % post-processing
    if isnan(cost)
        cost = 1000;
    end

    % end the simulation
    disp('done')

end % end the function
