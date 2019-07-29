pHeader;

%% Introduction
% The purpose of this document is to demonstrate several types of filters applied
% to computational (Prinzian) data. Methods for computing the burst frequency
% and phase relationships are suggested. The neuron used is the ABPD computational
% composite from Prinz _et al._ 2004 Fig 2e.


create_pyloric;
x.t_end     = 10e3;
x.transpile;
x.compile;

V           = x.integrate;
t           = (1/1000)*x.dt*(1:length(V));

V           = V(1e5:end,1);
t           = t(1e5:end);

figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
plot(t,V)
ylabel('membrane potential')
ylim([-80 60])
xlabel('time (s)')
prettyFig()

if being_published
  snapnow
  delete(gcf)
end

%% Introduction
% The purpose of this document is to demonstrate several types of filters applied
% to computational (Prinzian) data. Methods for computing the burst frequency
% and phase relationships are suggested. The neuron used is the ABPD computational
% composite from Prinz _et al._ 2004 Fig 2e.



T           = floor(1000/x.dt);
Vf          = filtfilt(ones(1,T),T,V);

figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
plot(t,V); hold on;
plot(t,Vf);
ylabel('membrane potential')
ylim([-80 60])
xlabel('time (s)')
prettyFig()

if being_published
  snapnow
  delete(gcf)
end

%% Digital Filter
% Median filter with sliding bin of 1 second.


sample_rate = 1e3/x.dt; % Hz
[B,A]       = butter(2,1/sample_rate);
Vf          = filtfilt(B,A,V);

figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
plot(t,V); hold on;
plot(t,Vf);
ylabel('membrane potential')
ylim([-80 60])
xlabel('time (s)')
prettyFig()

if being_published
  snapnow
  delete(gcf)
end


%% Butterworth Filter
% The Butterworth filter designs an Nth order low-pass digital filter. This is a
% second order Butterworth filter with a cutoff at 1 Hz. Higher order filtering
% will result in more variable oscillations.


window_size = 60;
Vf = zeros(length(V),5);
for ii = 1:2:5
  T = floor((ii*window_size/x.dt)/2)*2 + 1;
  Vf(:,ii) = sgolayfilt(V(:,1), 1, T);
end

figure('outerposition',[2 2 1500 1000],'PaperUnits','points','PaperSize',[1000 1000]);
plot(t,V); hold on;
plot(t,Vf);
ylabel('membrane potential')
ylim([-80 -20])
xlabel('time (s)')
legend({'raw','60 ms','180 ms','300 ms'},'Location','best')
prettyFig()

if being_published
  snapnow
  delete(gcf)
end

%% Savitzky-Golay Filter
% This might be the most useful filter for the computational models of the STG.
% It smoothes the data using a series of low-degree polynomials, fitting with a
% linear least-squares method. The bin-size dramatically changes the rapid oscillations
% which characterize the spiking region.
