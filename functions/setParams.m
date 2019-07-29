function setParams(x,params,params2vary)
  if nargin < 3
    load('~/code/pyloric-simulator/data/network/params2vary.mat')
  end
  for ii = 1:length(params2vary)
    eval(['x.' params2vary{ii} '=' num2str(params(ii)) ';']);
  end
end
