function [spikes,spiketimes] = volt2spikes(t,V)

  if isvector(V)
    % converts a vector of spike times to a vector of spikes
    spiketimes          = nonnans(psychopomp.findNSpikes(V,1000));
    spikes              = zeros(length(t),1);
    spikes(spiketimes)  = 1;
  else
    spikes              = zeros(length(t),size(V,2));
    spiketimes          = NaN(1000,size(V,2));
    for ii = 1:size(V,2)
      % converts a vector of spike times to a vector of spikes
      spiketimes(:,ii)                = psychopomp.findNSpikes(V(:,ii),1000);
      spikes(nonnans(spiketimes(:,ii)),ii)     = 1;
    end
end
