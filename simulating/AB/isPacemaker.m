
function [C, cost_vector, burst_freq, duty_cycle, min_slow_wave, max_slow_wave] = isPacemaker(x)

% first, make the default cost_vector
cost_vector = zeros(4,1);
cost_vector(1) = 1e5; % is it bursting?
cost_vector(2) = 1e4;
cost_vector(3) = 1e3;
cost_vector(4) = 1e2;

burst_freq = NaN;
duty_cycle = NaN;
min_slow_wave = NaN;
max_slow_wave = NaN;


C = sum(cost_vector(:));


;;;;;;;;     ;;;    ;;;;;;;;     ;;;    ;;     ;;  ;;;;;;
;;     ;;   ;; ;;   ;;     ;;   ;; ;;   ;;;   ;;; ;;    ;;
;;     ;;  ;;   ;;  ;;     ;;  ;;   ;;  ;;;; ;;;; ;;
;;;;;;;;  ;;     ;; ;;;;;;;;  ;;     ;; ;; ;;; ;;  ;;;;;;
;;        ;;;;;;;;; ;;   ;;   ;;;;;;;;; ;;     ;;       ;;
;;        ;;     ;; ;;    ;;  ;;     ;; ;;     ;; ;;    ;;
;;        ;;     ;; ;;     ;; ;;     ;; ;;     ;;  ;;;;;;


CV_Ca_peak_period_range = [0 .1];
n_spikes_per_burst_range = [4 30];
max_min_V_within_burst = -40;
cycle_period_range = [1.23/4 1.788*2]; % mean +/- 1 SD
burst_duration_range = [0.4490/4  0.7150*2]; % PD, sec
duty_cycle_range = [.3450 .4250];


;;       ;;;;;;;; ;;     ;; ;;;;;;;; ;;             ;;
;;       ;;       ;;     ;; ;;       ;;           ;;;;
;;       ;;       ;;     ;; ;;       ;;             ;;
;;       ;;;;;;   ;;     ;; ;;;;;;   ;;             ;;
;;       ;;        ;;   ;;  ;;       ;;             ;;
;;       ;;         ;; ;;   ;;       ;;             ;;
;;;;;;;; ;;;;;;;;    ;;;    ;;;;;;;; ;;;;;;;;     ;;;;;;

level_cost = 1e5;


% clone gbars from first compartment into 2nd compartment
gbar_in_neurite = x.get(x.find('Neurite*gbar'));
x.set(x.find('Soma*gbar'),gbar_in_neurite);
% set NaV in somatic compartment to zero
x.Soma.NaV.gbar = 0;

[V,Ca] = x.integrate;
cutoff = floor(10e3/x.dt);
V = V(cutoff:end,1); % discard 2nd compartment
Ca = Ca(cutoff:end,:);
Ca = Ca(:,1);


spike_times = psychopomp.findNSpikes(V,1e3);
n_spikes = sum(~isnan(spike_times));
if n_spikes > 0
	% penalize based on expected # of spikes
	min_expected_cycles = (x.t_end*1e-3)/cycle_period_range(2);
	min_expected_spikes = min_expected_cycles*n_spikes_per_burst_range(1);
	if n_spikes < min_expected_spikes
		cost_vector(1) = level_cost*(n_spikes/min_expected_spikes);
	else
		% OK, zero cost
		cost_vector(1) = 0;
	end
else
	% give it a cost that grows with how hyperpolarized it is
	if max(V) > 0
		% always above zero
		cost_vector(1) = level_cost;
	else
		cost_vector(1) = (0 - min(V))*level_cost;
	end

end

spike_times = spike_times*x.dt*1e-3;


time = (1:length(V))*x.dt*1e-3;

if nargout == 0
	figure('outerposition',[300 300 1200 300],'PaperUnits','points','PaperSize',[1200 900]); hold on
	plot(time,V,'k')
end

C = sum(cost_vector(:));

if nargout == 0
	disp(['This level cost is ' oval(cost_vector(1))])
end

if cost_vector(1) > 1
	return
end

;;       ;;;;;;;; ;;     ;; ;;;;;;;; ;;           ;;;;;;;
;;       ;;       ;;     ;; ;;       ;;          ;;     ;;
;;       ;;       ;;     ;; ;;       ;;                 ;;
;;       ;;;;;;   ;;     ;; ;;;;;;   ;;           ;;;;;;;
;;       ;;        ;;   ;;  ;;       ;;          ;;
;;       ;;         ;; ;;   ;;       ;;          ;;
;;;;;;;; ;;;;;;;;    ;;;    ;;;;;;;; ;;;;;;;;    ;;;;;;;;;

level_cost = 1e4;

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% cell is bursting, with an OK # of spikes/burst
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% step 1 of 3. now we check to see if the minimum calcium is less
% that 10% of the peak


cost_vector(2) = bin_cost([0,.1],min(Ca)/max(Ca))*level_cost/3;



% early exit
if cost_vector(2) > 1

	if nargout == 0
		disp('Aborting, because Calcium peaks are not <10% max')
	end

	C = sum(cost_vector(:));
	return
end


% figure out burst starts and stops based on calcium
% signals
Ca_peak_times = NaN(100,1);
Ca_min_times = NaN(100,1);
Ca_peak_values = NaN(100,1);



[ons,offs] = computeOnsOffs(Ca > mean(Ca)/2);

if length(ons) ~= length(offs)

	if nargout == 0
		disp('Aborting, because ons and offs have different lengths')
	end

	return
end

% find peaks b/w ons and offs
for j = 1:length(ons)
	[Ca_peak_values(j),idx] = max(Ca(ons(j):offs(j)));
	Ca_peak_times(j) = ons(j) + idx - 1;
end

% find mins b/w offs and next ons
try
    for j = 1:length(ons)-1
        [~,idx] = max(-Ca(offs(j):ons(j+1)));
        Ca_min_times(j) = offs(j) + idx - 1;
    end
catch
    if nargout == 0
        disp('Aborting, I skipped a peak')
    end
    return
end


if nargout == 0

	figure('outerposition',[300 300 1200 300],'PaperUnits','points','PaperSize',[1200 900]); hold on
	plot(time,Ca,'k')
	temp = nonnans(Ca_peak_times);
	plot(time(temp),Ca(temp),'ro')

	temp = nonnans(Ca_min_times);
	plot(time(temp),Ca(temp),'bo')


end


% convert these things into seconds
Ca_peak_times = Ca_peak_times*x.dt*1e-3;
Ca_min_times = Ca_min_times*x.dt*1e-3;

% make sure there are more than 3 peaks
if length(nonnans(Ca_peak_times)) < 3
	C = C + 1e4;
	return
end

% step 2 of 3 -- check that Ca peaks occur regularly

this_cv = cv(diff(nonnans(Ca_peak_times)));
cost_vector(2) = cost_vector(2) +  level_cost*bin_cost(CV_Ca_peak_period_range,this_cv)/3;




% let's also store all the durations
% and the # of spikes per burst
all_durations = NaN(100,1);
n_spikes_in_burst = NaN(100,1);
all_burst_starts = NaN(100,1);
all_burst_ends = NaN(100,1);

% check for depolarization block

n_bursts = sum(~isnan(Ca_min_times));
for j = 1:n_bursts-1

	a = Ca_min_times(j);
	z = (Ca_min_times(j+1) - a)*.9 + a;

	spikes_in_this_burst = spike_times(a <= spike_times & z >= spike_times);

	n_spikes_in_burst(j) = length(spikes_in_this_burst);

	% measure the duration of this burst
	if length(spikes_in_this_burst) > 1
		all_durations(j) = spikes_in_this_burst(end) - spikes_in_this_burst(1);
		all_burst_starts(j) = spikes_in_this_burst(1);
		all_burst_ends(j) = spikes_in_this_burst(end);
	else
		all_durations(j) = 0;
		continue
	end
end



% penalize things that are outside the allowed
% # of spikes/burst


this_n_spikes = nonnans(n_spikes_in_burst);
frac_cost = (level_cost/3)/length(this_n_spikes);
for j = 1:length(this_n_spikes)
	if (this_n_spikes(j) <= n_spikes_per_burst_range(2)) && (this_n_spikes(j) >= n_spikes_per_burst_range(1))
	else
		cost_vector(2) = cost_vector(2) + frac_cost;
	end
end



C = sum(cost_vector(:));


if any(cost_vector(2,:) > 1)
	return
end


;;       ;;;;;;;; ;;     ;; ;;;;;;;; ;;           ;;;;;;;
;;       ;;       ;;     ;; ;;       ;;          ;;     ;;
;;       ;;       ;;     ;; ;;       ;;                 ;;
;;       ;;;;;;   ;;     ;; ;;;;;;   ;;           ;;;;;;;
;;       ;;        ;;   ;;  ;;       ;;                 ;;
;;       ;;         ;; ;;   ;;       ;;          ;;     ;;
;;;;;;;; ;;;;;;;;    ;;;    ;;;;;;;; ;;;;;;;;     ;;;;;;;

% level 3 is all about the depolarization block. we don't
% want that. we hate depol. blocks. bad block.

level_cost = 1e3;
cost_vector(3,:) = 0;

% check 1/2: measure V inbetween spikes

n_bursts = sum(~isnan(n_spikes_in_burst));
frac_cost = (level_cost/2)/n_bursts;
for j = 1:n_bursts
	spikes_in_this_burst = spike_times(all_burst_starts(j) <= spike_times & all_burst_ends(j) >= spike_times);
	between_spikes = spikes_in_this_burst(1:end-1) + diff(spikes_in_this_burst)/2;

	max_V = max(V(round(between_spikes*1e3/x.dt)));
	cost_vector(3) = cost_vector(3) + bin_cost([-60, -35],max_V)*frac_cost;

end



% check 2/2 ISIs during bursts

n_bursts = sum(~isnan(n_spikes_in_burst));
frac_cost = (level_cost/2)/n_bursts;
for j = 1:n_bursts
	spikes_in_this_burst = spike_times(all_burst_starts(j) <= spike_times & all_burst_ends(j) >= spike_times);
	isis_in_this_burst = diff(spikes_in_this_burst);



	isi_ratio = max(isis_in_this_burst)/mean(setdiff(isis_in_this_burst,max(isis_in_this_burst)));
	cost_vector(3) = cost_vector(3) + bin_cost([0 5],isi_ratio)*frac_cost;

end


C = sum(cost_vector(:));

if cost_vector(3) > 1
	return
end

;;       ;;;;;;;; ;;     ;; ;;;;;;;; ;;          ;;
;;       ;;       ;;     ;; ;;       ;;          ;;    ;;
;;       ;;       ;;     ;; ;;       ;;          ;;    ;;
;;       ;;;;;;   ;;     ;; ;;;;;;   ;;          ;;    ;;
;;       ;;        ;;   ;;  ;;       ;;          ;;;;;;;;;
;;       ;;         ;; ;;   ;;       ;;                ;;
;;;;;;;; ;;;;;;;;    ;;;    ;;;;;;;; ;;;;;;;;          ;;

% here we check that neuron-specific parameters like the period, duration and duty cycle are within the experimental range.

level_cost = 1e2;
cost_vector(4) = 0;

% measure burst frequencies of neuron
all_periods = mean(diff(nonnans(Ca_min_times)));



% penalize them based on how far they are from the
% experimental range
cost_vector(4) = cost_vector(4) + bin_cost(cycle_period_range,all_periods);


% durations
cost_vector(4) = cost_vector(4) + level_cost*bin_cost(burst_duration_range,nanmean(all_durations));


% duty cycle
all_duty_cycle = nanmean(all_durations)./all_periods;

cost_vector(4) = cost_vector(4) + level_cost*bin_cost(duty_cycle_range,all_duty_cycle);


C = sum(cost_vector(:));


% outputs
burst_freq = 1./ mean(all_periods);
duty_cycle = mean(all_duty_cycle);
[min_slow_wave, max_slow_wave] = findSlowWaveStats(x,V);


function c = bin_cost(allowed_range,actual_value)


	w = (allowed_range(2) - allowed_range(1))/2;
	m = (allowed_range(2) + allowed_range(1))/2;

	if actual_value < allowed_range(1)
		d = m - actual_value;
		c = (1- (w/d));
	elseif actual_value > allowed_range(2)
		d = actual_value - m;
		c = (1- (w/d));
	else
		% no cost
		c = 0;
	end

end

end % end function
