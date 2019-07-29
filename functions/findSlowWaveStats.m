function [min_slow_wave, max_slow_wave, Vf] = findSlowWaveStats(timestep,V,window_size)

% compute the baseline of the slow-wave
if nargin < 3
  window_size = 300;
end

% properly-sized windows prevent piss-poor performance
T = floor((window_size/timestep)/2)*2 + 1;

% get all Savitzy-Golay up in here
Vf              = sgolayfilt(V, 1, T);
min_slow_wave   = min(V);
max_slow_wave   = max(Vf);
