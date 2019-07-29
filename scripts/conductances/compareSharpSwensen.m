% compares the Sharp et al 1993 and Swensen & Marder 2001 modulatory input conductances

x = xolotl;
[minf_Sharp, ~, ~, ~, mphq_Sharp, ~]     = x.getGatingFunctions('sharp/MICurrent');
[minf_Swens, ~, ~, ~, mphq_Swens, ~]     = x.getGatingFunctions('swensen/MICurrent');

% compute the IV curves
V = linspace(-80,80,1e3);
I_Sharp         = mphq_Sharp .* (V - (-10) );
I_Swens         = mphq_Swens .* (V - (-22) );

% make plots
figure('outerposition',[100 100 1000 500],'PaperUnits','points','PaperSize',[1000 1000]);
lgd = {'Sharp ''93' 'Swensen ''01'};
ax(1) = subplot(1,2,1); hold on
plot(V,minf_Sharp); plot(V,minf_Swens);
ax(2) = subplot(1,2,2); hold on
plot(V,I_Sharp); plot(V,I_Swens);
xlabel(ax(1),'membrane potential (mV)')
xlabel(ax(2),'membrane potential (mV)')
ylabel(ax(1),'m_∞(V)')
ylabel(ax(2),'normalized current (nA / \muS)')
legend(ax(1),lgd)
legend(ax(2),lgd)
prettyFig('fs',12)
