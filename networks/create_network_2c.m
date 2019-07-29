% produce a triphasic network, using 2-compartment models
% the "primary" compartment is the spike-initiation/axonal compartment
% the "secondary" compartment is the soma/neurite compartment

x = xolotl;
x.closed_loop = false;
x.skip_hash_check = true;
x.cleanup;

% conversion from Prinz to phi
vol = 1; % this can be anything, doesn't matter
f = 14.96; % uM/nA
tau_Ca = 200;
F = 96485; % Faraday constant in SI units
phi = (2*f*F*vol)/tau_Ca;

x.addCompartment('AB',-65,0.02,10,0.0628,vol,phi,3000,0.05,tau_Ca,0);
x.addConductance('AB','prinz-fast/NaV',4000,50);
x.addConductance('AB','prinz-fast/CaT',25,30);
x.addConductance('AB','prinz-fast/CaS',60,30);
x.addConductance('AB','prinz-fast/ACurrent',500,-80);
x.addConductance('AB','prinz-fast/KCa',100,-80);
x.addConductance('AB','prinz-fast/Kd',1000,-80);
x.addConductance('AB','prinz-fast/HCurrent',.1,-20);

x.addCompartment('LP',-47,0.02,10,0.0628,vol,phi,3000,0.05,tau_Ca,0);
x.addConductance('LP','prinz-fast/NaV',1000,50);
x.addConductance('LP','prinz-fast/CaT',0,30);
x.addConductance('LP','prinz-fast/CaS',40,30);
x.addConductance('LP','prinz-fast/ACurrent',200,-80);
x.addConductance('LP','prinz-fast/KCa',0,-80);
x.addConductance('LP','prinz-fast/Kd',250,-80);
x.addConductance('LP','prinz-fast/HCurrent',.5,-20);
% x.addConductance('LP','Leak',.3,-50);

x.addCompartment('PY',-41,0.02,10,0.0628,vol,phi,3000,0.05,tau_Ca,0);
x.addConductance('PY','prinz-fast/NaV',1000,50);
x.addConductance('PY','prinz-fast/CaT',25,30);
x.addConductance('PY','prinz-fast/CaS',20,30);
x.addConductance('PY','prinz-fast/ACurrent',500,-80);
x.addConductance('PY','prinz-fast/KCa',0,-80);
x.addConductance('PY','prinz-fast/Kd',1250,-80);
x.addConductance('PY','prinz-fast/HCurrent',.5,-20);
% x.addConductance('PY','Leak',.1,-50);

% chemical synapses
x.addSynapse('Chol','AB','LP',30);
x.addSynapse('Chol','AB','PY',3);
x.addSynapse('Glut','AB','LP',30);
x.addSynapse('Glut','AB','PY',10);
x.addSynapse('Glut','LP','PY',1);
x.addSynapse('Glut','PY','LP',30);
x.addSynapse('Glut','LP','AB',30);

% add auxiliary compartments
x.addCompartment('ABSN',-65,0.02,10,0.0628,vol,phi,3000,0.05,tau_Ca,0);
% x.addConductance('ABSN','prinz-fast/NaV',4000,50);
x.addConductance('ABSN','prinz-fast/CaT',25,30);
x.addConductance('ABSN','prinz-fast/CaS',60,30);
x.addConductance('ABSN','prinz-fast/ACurrent',500,-80);
x.addConductance('ABSN','prinz-fast/KCa',100,-80);
x.addConductance('ABSN','prinz-fast/Kd',1000,-80);
x.addConductance('ABSN','prinz-fast/HCurrent',.1,-20);

x.addCompartment('LPSN',-47,0.02,10,0.0628,vol,phi,3000,0.05,tau_Ca,0);
% x.addConductance('LPSN','prinz-fast/NaV',1000,50);
x.addConductance('LPSN','prinz-fast/CaT',0,30);
x.addConductance('LPSN','prinz-fast/CaS',40,30);
x.addConductance('LPSN','prinz-fast/ACurrent',200,-80);
x.addConductance('LPSN','prinz-fast/KCa',0,-80);
x.addConductance('LPSN','prinz-fast/Kd',250,-80);
x.addConductance('LPSN','prinz-fast/HCurrent',.5,-20);
% x.addConductance('LPSN','Leak',.3,-50);

x.addCompartment('PYSN',-41,0.02,10,0.0628,vol,phi,3000,0.05,tau_Ca,0);
% x.addConductance('PYSN','prinz-fast/NaV',1000,50);
x.addConductance('PYSN','prinz-fast/CaT',25,30);
x.addConductance('PYSN','prinz-fast/CaS',20,30);
x.addConductance('PYSN','prinz-fast/ACurrent',500,-80);
x.addConductance('PYSN','prinz-fast/KCa',0,-80);
x.addConductance('PYSN','prinz-fast/Kd',1250,-80);
x.addConductance('PYSN','prinz-fast/HCurrent',.5,-20);
% x.addConductance('PYSN','Leak',.1,-50);

% connect empty compartments
x.connect('ABSN','AB',100);
x.connect('LPSN','LP',100);
x.connect('PYSN','PY',100);

x.t_end = 20e3;
x.transpile;
x.compile;
