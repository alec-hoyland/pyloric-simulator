% load bursting Prinz models with NaV and CaT removed
% which initially were not oscillating but do with added modulatory input
% which have been excised and optimzied with procrustes
% according to the comfyChair/AB_simulation_function protocol
data = load('data_Prinz_bursting_TTX_CaT_nosc_gMI_ex_pro.mat')
params = data.params;
% clean up the parameters by rounding
for ii = 1:9
  for qq = 1:length(data.params)
    if params(qq,ii) > 1
      params(qq,ii) = round(params(qq,ii));
    end
  end
end
% keep only the parameter sets that oscillate at gMI = 0.02 μS/mm^2
keep_this = [3 4 5 6 7 8 9 10 11 15 27];
params = params(keep_this,:);
