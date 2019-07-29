function counter = isBlocked(V, spike_times, Ca_peaks, burst_data)

if size(burst_data,1) < size(burst_data,2)
    burst_data = burst_data';
end

nBursts = size(burst_data,2);

% get absolute burst start and stop times
Ca_peaks    = Ca_peaks(2:end-1);
bStarts     = Ca_peaks + burst_data(:,2);
bStops      = Ca_peaks + burst_data(:,3);

% spikes in burst
sBurst      = cell(nBursts,1);
ISI         = cell(nBursts,1);
for ii = 1:nBursts
    sBurst{ii}  = spike_times(spike_times >= bStarts(ii) & spike_times <= bStops(ii));
    ISI{ii}     = diff(sBurst{ii});
end

% check that each ISI is less than a tolerance threshold
counter     = 0;
ISI_tol     = 2 * (bStops(ii) - bStarts(ii)) ./ burst_data(:,1);
for ii = 1:nBursts
    for qq = 1:length(ISI{ii})
        if ISI{ii}(qq) > ISI_tol(ii)
            counter = counter + 1;
        end
    end
end

% measure V in-between spikes
for ii = 1:nBursts
    betweenSpikes      = sBurst{ii}(1:end-1) + diff(sBurst{ii})/2;
    Vmax               = max(V(round(betweenSpikes)));
    if Vmax > -35 | Vmax < -60
        counter = counter + 1;
    end
end

% return
counter;
