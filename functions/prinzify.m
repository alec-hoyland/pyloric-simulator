function prinzify(x,AB,LP,PY,syn)

  % create maximal conductance matrix
  ABcond          = zeros(5,9);
  LPcond          = zeros(5,9);   % μS/cm^2
  PYcond          = zeros(6,9);

  ABcond(1,:)     = [400 2.5 6 50 10 100 0.01 0.00 0];
  ABcond(2,:)     = [100 2.5 6 50 5 100 0.01 0.00 0];
  ABcond(3,:)     = [200 2.5 4 50 5 50 0.01 0.00 0];
  ABcond(4,:)     = [200 5.0 4 40 5 125 0.01 0.00 0];
  ABcond(5,:)     = [300 2.5 2 10 5 125 0.01 0.00 0];

  LPcond(1,:)     = [100 0 8 40 5 75 0.05 0.02 0];
  LPcond(2,:)     = [100 0 6 40 5 50 0.05 0.02 0];
  LPcond(3,:)     = [100 0 10 50 5 100 0.00 0.03 0];
  LPcond(4,:)     = [100 0 4 20 0 25 0.05 0.03 0];
  LPcond(5,:)     = [100 0 6 30 0 50 0.03 0.02 0];

  PYcond(1,:)     = [100 2.5 2 50 0 125 0.05 0.01 0];
  PYcond(2,:)     = [200 7.5 0 50 0 75 0.05 0.00 0];
  PYcond(3,:)     = [200 10 0 50 0 100 0.03 0.00 0];
  PYcond(4,:)     = [400 2.5 2 50 0 75 0.05 0.00 0];
  PYcond(5,:)     = [500 2.5 2 40 0 125 0.01 0.03 0];
  PYcond(6,:)     = [500 2.5 2 40 0 125 0.00 0.02 0];

  % create maximal synaptic conductance matrix
  g_syns          = zeros(7,7);

  g_syns(1,:)     = [10 10 100 3 30 1 3];
  g_syns(2,:)     = [3 0 0 30 3 3 0];
  g_syns(3,:)     = [100 30 0 1 0 3 0];
  g_syns(4,:)     = [3 10 100 1 10 3 10];
  g_syns(5,:)     = [30 10 30 3 30 1 30];
  g_syns(6,:)     = [3 10 100 1 10 3 10];
  g_syns(7,:)     = [0 0 0 0 0 0 0];

  ABcond          = ABcond * 10;
  LPcond          = LPcond * 10;    % μS/mm^2
  PYcond          = PYcond * 10;
  g_syns          = g_syns * 10;

  x.setConductances(1,ABcond(AB,:))
  x.setConductances(2,LPcond(LP,:))
  x.setConductances(3,PYcond(PY,:))

  for ii = 1:length(x.synapses)
    x.synapses(ii).gbar = g_syns(syn,ii);
  end
end
