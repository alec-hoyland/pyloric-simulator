% create_AB
% x.AB.add('swensen/MICurrent','gbar',0,'E',-22);
%
% data = load('data_Prinz_bursting_TTX_CaT_nosc_gMI_Swensen.mat')
%
% newParams(1,:) = data.params(4,:);
% newParams(2,:) = data.params(3,:);
% newParams(3,:) = data.params(7,:);
% newParams(4,:) = data.params(5,:);
% newParams(5,:) = data.params(6,:);
% newParams(6,:) = zeros(1,size(data.params,2));
%
% index = [1 4704 4740];
% index = [13315 2437 9590]
% index = [13315 14160 9590]
%
% figure;
% for ii = 1:6
%     ax(ii) = subplot(3,2,ii);
% end
%
% for ii = 1:3
%     x.set(x.find('*gbar'),newParams(:,index(ii)));
%     x.reset;
%     V(:,ii) = x.integrate;
%
%     x.AB.MICurrent.gbar = 1.0;
%     x.reset;
%     V2(:,ii) = x.integrate;
% end
%
% time = x.dt / 1000 * (1:length(V));
% for ii = 1:3
%     plot(ax(2*ii-1),time,V(:,ii),'k');
%     plot(ax(2*ii),time,V2(:,ii),'r');
% end
%
% for ii = 5:6
%     xlabel(ax(ii),'time (s)')
% end
%
% for ii = 1:2:6
%     ylabel(ax(ii),'V_m (mV)')
% end
%
% prettyFig('fs',36,'plw',2);
% equalizeAxes(ax); linkaxes(ax);
%
%
% return

  modelNames          = {'AB','LP'}
  modelIndices        = {1:30};
  modelParams         = NaN(28,0);

  for qq = 1:length(modelNames)
    allfiles = dir(['data_optim_network_' modelNames{qq} '*.mat']);

    cost              = NaN(2e3,1);
    metrics						= NaN(24,2e3);
    metrics_MI 				= NaN(24,2e3);
    params 						= NaN(29,2e3);

    for ii = 1:length(allfiles)
      disp(allfiles(ii).name)
      data = load(allfiles(ii).name);

      passing		 			= ~isnan(data.cost);
      data.cost 			= data.cost(passing);
      data.params 		= data.params(:,passing);
      parameter_names = data.parameter_names;

      a = find(isnan(cost),1,'first');
      z = a + length(data.cost) - 1;

      % assemble
      cost(a:z) 			= data.cost;
      params(:,a:z) 	= data.params;
    end

    % trim
    a 								= find(isnan(cost),1,'first');
    params 						= params(:,1:a-1);
    modelParams       = [modelParams params(1:28,:)];
  end

clear cost;
if ~exist('data_for_figs.mat')
    make_stg

    x.AB.add('swensen/MICurrent','gbar',0,'E',-22);
    x.LP.add('swensen/MICurrent','gbar',0,'E',-22);

    parameter_names = parameter_names(1:28);

    cost = NaN(length(modelParams),4);

    for ii = 1:length(modelParams)
        textbar(ii,length(modelParams))

        x.reset;
        x.set(parameter_names,modelParams(:,ii));
        x.AB.MICurrent.gbar = 0;
        x.LP.MICurrent.gbar = 0;
        cost(ii,1) = isPyloric(x);

        x.reset;
        x.AB.MICurrent.gbar = 1;
        x.LP.MICurrent.gbar = 0;
        cost(ii,2) = isPyloric(x);

        x.reset;
        x.AB.MICurrent.gbar = 0;
        x.LP.MICurrent.gbar = 1;
        cost(ii,3) = isPyloric(x);

        x.reset;
        x.AB.MICurrent.gbar = 1;
        x.LP.MICurrent.gbar = 1;
        cost(ii,4) = isPyloric(x);
    end
    save('data_for_figs.mat', 'cost')
else
    load('data_for_figs.mat')
end

%% Do this next

% passing models are defined as those which have a cost less than 500 or the median, whichever is lower
passing = cost < median(vectorise(cost));

figure('PaperUnits', 'inches', 'PaperSize', [4 8]);
c = linspecer(5);

subplot(1,2,1);
count_state = sum(passing);
p = pie([count_state(1), sum(count_state)-count_state(1)], ...
    {['non-pyloric ' num2str(count_state(1))]; ['pyloric ' num2str(sum(count_state)-count_state(1))]});
p(1).FaceColor = c(5,:);
p(3).FaceColor = c(1,:);
title({'activity classification'; 'when decentralized'})
% b.CData = c;
% set(gca,'xticklabel',{'dec.','AB-PD','LP','AB-PD & LP'})
% xlabel('modulation at 1 \muS/mm^2')
% ylabel('number of models')
% title('triphasic model networks by modulation state')

subplot(1,2,2);
recovering_all = sum(passing(passing(:,1) == 0,:));
b = bar(recovering_all(2:4), 'FaceColor', 'flat');
b.CData = c(2:4,:);
set(gca,'xticklabel',{'AB-PD','LP','AB-PD & LP'})
xlabel('modulation at 1 \muS/mm^2')
ylabel('number of models')
title({'non-pyloric when decentralized'; 'by modulation state'})

prettyFig('fs',20)
% equalizeAxes()

% correlation between modulation states for each model
corr_mod_states = corr(passing);

% models which are not triphasic in the decentralized condition
% and recover with modulation into ABPD and LP
recovering_ABLP = passing(passing(:,1) == 0 & passing(:,4) == 1,:);
recovering_params = modelParams(:,recovering_ABLP);

% seed parameters
data2 = load('all_networks.mat')
seed_params = data2.g;

% do kolmogorov-smirnov tests
clear H p;
for ii = 1:28
    for qq = 1:28
        x1 = [recovering_params(ii,:); recovering_params(qq,:)]';
        x2 = [seed_params(ii,:); seed_params(qq,:)]';
        [H(ii,qq), p(ii,qq)] = kstest_2s_2d(x1, x2);
    end
end


for ii = 1:3 % for each cell
    params1 = recovering_params( 7*(ii - 1) + 1 : 7*ii, : );
    params2 = seed_params( 7*(ii - 1) + 1 : 7*ii, : );
    signi = H( 7*(ii - 1) + 1 : 7*ii, 7*(ii - 1) + 1 : 7*ii );

    figure; clear ax;
    for qq = 1:49
        ax(qq) = subplot(7,7,qq);
        hold(ax(qq), 'on');
    end

    % set axis labels
    cond_names = {'A', 'CaS', 'CaT', 'H', 'KCa', 'Kd', 'NaV'};
    for qq = 1:7
        xlabel(ax(7*(7-1)+qq), cond_names{qq});
        ylabel(ax(7*(qq-1)+1), cond_names{qq});
    end

    % make histograms of each condition
    c = linspecer(2);
    c(1,:) = [0 0 0];
    for qq = 1:7
        index = 7*(qq - 1) + qq;

        bin_vec = linspace(0,max(vectorise(params2(qq,:))),30);
        [n h] = histcounts(params1(qq,:), bin_vec);
        center = h(1:end-1) + mean(diff(h));
        n = n / length(params1(qq,:));
        stairs(ax(index), center, n, 'Color', c(2,:));

        [n h] = histcounts(params2(qq,:), bin_vec);
        center = h(1:end-1) + mean(diff(h));
        n = n / length(params2(qq,:));
        stairs(ax(index), center, n, 'Color', c(1,:));
    end

    % create correlations along the axes where ii ≢ qq
    for ii = 1:7
      for qq = 1:7
        if ii ~= qq
          index = 7*(ii-1) + qq;
          % scatter(ax(index), params_expro(qq,:), params_expro(ii,:), 20, c(3,:), 'filled',  'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1);
          scatter(ax(index), params1(qq,:), params1(ii,:), 10, c(2,:), 'filled', 'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1);
          scatter(ax(index), params2(qq,:), params2(ii,:), 10, c(1,:), 'filled', 'MarkerFaceAlpha', 0.1, 'MarkerEdgeAlpha', 0.1);
          xlim(ax(index), [0 max(vectorise(params2(qq,:)))]);
          ylim(ax(index), [0 max(vectorise(params2(ii,:)))]);
        end
      end
    end

    prettyFig()
    for ii = 1:49
        if signi(ii) == true
            ax(ii).LineWidth = 6;
        end
    end

end

params1 = recovering_params(22:28, :);
params2 = seed_params(22:28, :);
signi = H(22:28, 22:28);

figure; clear ax;
for qq = 1:49
    ax(qq) = subplot(7,7,qq);
    hold(ax(qq), 'on');
end

% set axis labels
cond_names = {'PD→LP', 'PD→PY', 'AB→LP', 'AB→PY', 'LP→PY', 'PY→LP', 'LP→PD'};
for qq = 1:7
    xlabel(ax(7*(7-1)+qq), cond_names{qq});
    ylabel(ax(7*(qq-1)+1), cond_names{qq});
end

% make histograms of each condition
c = linspecer(2);
c(1,:) = [0 0 0];
for qq = 1:7
    index = 7*(qq - 1) + qq;

    bin_vec = linspace(0,max(vectorise(params2(qq,:))),30);
    [n h] = histcounts(params1(qq,:), bin_vec);
    center = h(1:end-1) + mean(diff(h));
    n = n / length(params1(qq,:));
    stairs(ax(index), center, n, 'Color', c(2,:));

    [n h] = histcounts(params2(qq,:), bin_vec);
    center = h(1:end-1) + mean(diff(h));
    n = n / length(params2(qq,:));
    stairs(ax(index), center, n, 'Color', c(1,:));
end

% create correlations along the axes where ii ≢ qq
for ii = 1:7
  for qq = 1:7
    if ii ~= qq
      index = 7*(ii-1) + qq;
      % scatter(ax(index), params_expro(qq,:), params_expro(ii,:), 20, c(3,:), 'filled',  'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1);
      scatter(ax(index), params1(qq,:), params1(ii,:), 10, c(2,:), 'filled', 'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1);
      scatter(ax(index), params2(qq,:), params2(ii,:), 10, c(1,:), 'filled', 'MarkerFaceAlpha', 0.1, 'MarkerEdgeAlpha', 0.1);
      xlim(ax(index), [0 max(vectorise(params2(qq,:)))]);
      ylim(ax(index), [0 max(vectorise(params2(ii,:)))]);
    end
  end
end

% beautify and describe correlations
prettyFig()
for ii = 1:49
    if signi(ii) == true
        ax(ii).LineWidth = 6;
    end
end


%% Plot Combined Metrics

% combined metrics
suffix = {'LP.mat','AB.mat','ABLP.mat'};
c = linspecer(3);

for ww = 1:3
    figure('PaperUnits', 'inches', 'PaperSize', [4 8]);

    for qq = 1:12
      ax(qq) = subplot(4,3,qq);
    end

    for ii = 1:3 % modulation
      load(['data_plot_network_' suffix{ii}])
      gMI = NaN(2,size(params,2));
      for qq = 1:size(params,2)
        gMI(:,qq) = linspace(0,params(end,qq),2);
      end

    % plot burst frequency
    hold(ax(ii),'on')
    plot(ax(ii), gMI, squeeze(burst_freq([1 end], ww, :)), '-o', 'Color', c(ww,:))

    % plot duty cycle
    hold(ax(ii + 3),'on')
    plot(ax(ii + 3), gMI, squeeze(duty_cycle([1 end], ww, :)), '-o', 'Color', c(ww,:))

    % plot mean number of spikes per burst
    hold(ax(ii + 6),'on')
    plot(ax(ii + 6), gMI, squeeze(nSpikes([1 end], ww, :)), '-o', 'Color', c(ww,:))

    % plot amplitude
    amplitude = max_slow_wave - min_slow_wave;
    hold(ax(ii + 9),'on')
    plot(ax(ii + 9), gMI, squeeze(amplitude([1 end], ww, :)), '-o', 'Color', c(ww,:))

    end

    % titles on the top three
    title(ax(1), {'Modulation onto'; 'LP'});
    title(ax(2), {'Modulation onto'; 'AB-PD'});
    title(ax(3), {'Modulation onto'; 'AB-PD & LP'});

    % x-labels on the bottom three
    for qq = 10:12
      xlabel(ax(qq), 'ḡ_{MI} (μS/mm^2)')
    end

    % y-labels on the left four
    ylabel(ax(1), {'burst frequency'; '(Hz)'})
    ylabel(ax(4), 'duty cycle')
    ylabel(ax(7), 'number of spikes per burst')
    ylabel(ax(10), {'slow wave'; 'amplitude'; '(mV)'});

    prettyFig('fs',20,'plw',1)
    equalizeAxes(ax(1:3))
    equalizeAxes(ax(4:6))
    equalizeAxes(ax(7:9))
    equalizeAxes(ax(10:12))

    linkaxes(ax(1:3))
    linkaxes(ax(4:6))
    linkaxes(ax(7:9))
    linkaxes(ax(10:12))
end
