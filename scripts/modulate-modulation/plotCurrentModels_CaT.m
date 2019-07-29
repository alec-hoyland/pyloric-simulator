% add CaT back into the models

create_Prinz  % create a single-compartment model
time = (x.dt:x.dt:x.t_end) / 1000;

% set CaT maximal conductance to nonzero value
params(:,2) = 2.5;
hash = dataHash([dataHash(params) dataHash({x.serialize})]);
data = cache(hash);

if ~isempty(data)
  V = data.V;
  V2 = data.V2;
else
  for ii = 1:length(params)
    textbar(ii,length(params))
    x.reset;  % be paranoid
    % set the conductances
    x.setConductances('Prinz',params(ii,:));
    % simulate the model
    V(:,ii) = x.integrate;
    % add in modulatory current
    x.Prinz.MICurrent.gbar = 0.02;
    V2(:,ii) = x.integrate;
  end
  traces.V = V;
  traces.V2 = V2;
  cache(hash,traces);
end

figure('outerposition',[2 2 2000 2000],'PaperUnits','points','PaperSize',[2000 2000])
subplot(2,1,1); plot(time,V); ylabel('membrane potential (mV)'); title('oscillating AB models with CaT & MI')
subplot(2,1,2); plot(time,V2); xlabel('time (s)'); ylabel('membrane potential (mV)')
equalizeAxes(); prettyFig('fs',24)

% plot robustness for the CaT case
plotRobustness(x,params,linspace(0,0.05,11),true,false)
