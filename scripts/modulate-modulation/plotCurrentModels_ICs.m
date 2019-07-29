% see if simulations are sensitive to initial conditions

create_Prinz  % create a single-compartment model
time = (x.dt:x.dt:x.t_end) / 1000;

% set depolarized initial condition
x.Prinz.V = 60; x.transpile; x.compile;
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
    x.Prinz.V = 60;   % instantaneously depolarize the cell
    V(:,ii) = x.integrate;
    % add in modulatory current
    x.Prinz.V = 60;   % instantaneously depolarize the cell
    x.Prinz.MICurrent.gbar = 0.02;
    V2(:,ii) = x.integrate;
  end
  traces.V = V;
  traces.V2 = V2;
  cache(hash,traces);
end

figure('outerposition',[2 2 2000 2000],'PaperUnits','points','PaperSize',[2000 2000])
subplot(2,1,1); plot(time,V); ylabel('membrane potential (mV)'); title('oscillating AB models with IC & MI')
subplot(2,1,2); plot(time,V2); xlabel('time (s)'); ylabel('membrane potential (mV)')
equalizeAxes(); prettyFig('fs',24)
