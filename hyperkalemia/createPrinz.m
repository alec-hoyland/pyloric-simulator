% conversion from Prinz to phi
vol = 1; % this can be anything, doesn't matter
f = 14.96; % uM/nA
tau_Ca = 200;
F = 96485; % Faraday constant in SI units
phi = (2*f*F*vol)/tau_Ca;

x = xolotl;

% Prinz neuron
x.addCompartment('Prinz',-65,0.02,10,0.0628,vol,phi,3000,0.05,tau_Ca,0);
x.addConductance('Prinz','prinz/NaV',1000,50);
x.addConductance('Prinz','prinz/CaT',25,30);
x.addConductance('Prinz','prinz/CaS',20,30);
x.addConductance('Prinz','prinz/ACurrent',500,-80);
x.addConductance('Prinz','prinz/KCa',5,-80)
x.addConductance('Prinz','prinz/Kd',1250,-80);
x.addConductance('Prinz','prinz/HCurrent',.5,-20);
x.addConductance('Prinz','Leak',.1,-50);

x.setConductances(1,[1000 25 60 500 50 1000 0.1 0])

x.dt                  = 50e-3;
x.t_end               = 20e3;
x.transpile;
x.compile;
x.closed_loop         = false;
x.skip_hash_check     = true;
