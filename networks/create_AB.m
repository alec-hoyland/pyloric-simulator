% geometry of soma is a sphere
A = 0.0628;
vol = 1;
f = 14.96; % uM/nA
tau_Ca = 200;
F = 96485; % Faraday constant in SI units
phi = (2*f*F*vol)/tau_Ca;

x = xolotl;
x.cleanup;
x.add('AB','compartment','Cm',10,'A',A,'vol',vol,'phi',phi,'Ca_out',3000,'Ca_in',0.05,'tau_Ca',tau_Ca);

g0 = 1e-1*rand(4,1);

x.AB.add('prinz/CaS','gbar',g0(1),'E',30);
x.AB.add('prinz/ACurrent','gbar',g0(2),'E',-80);
x.AB.add('prinz/KCa','gbar',g0(2),'E',-80);
x.AB.add('prinz/Kd','gbar',g0(3),'E',-80);
x.AB.add('prinz/HCurrent','gbar',g0(4),'E',-20);

x.dt = 0.1;
x.t_end = 20e3;
