% load bursting Prinz models with NaV and CaT removed
% which initially were not oscillating but do with added modulatory input
% which have been excised and optimzied with procrustes
% according to the comfyChair/AB_simulation_function protocol
getCurrentModels
% simulate and plot all of these models to demonstrate what they do
plotCurrentModels; close all;
% see if simulations are sensitive to initial conditions
plotCurrentModels_ICs; close all;
% add CaT back into the models
plotCurrentModels_CaT; close all;
% futz with modulatory input parameters
plotCurrentModels_MIcustom; close all;
