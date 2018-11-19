clearvars -except m*slide*

maxslide = maxslideZS;
titler = 'ZS max';
xlimer = [-20 500];
stimnamespot = -0.9;

bbnAll = {'BBN_30'};
toneAll = {'Hz_15000'; 'Hz_20000'; 'Hz_25000'; 'Hz_30000'; 'Hz_35000'; 'Hz_40000'};
syllableAll = {'Biosonar'; 'DFM_QCFl'; 'DFMl'; 'DFMl_QCFl_UFM'; 'DFMs'; 'QCF'; 'UFM'; 'rBNBl'; 'rBNBs'; 'sAFM'; 'sHFM'; 'sinFM'; 'torQCF'};
stringAll = {'App1_string'; 'App2_string'; 'High1_string'; 'High3_string'; 'Low3_string'; 'Med1_string'; 'Tone25_string'; 'search2_string'};
stimList = [bbnAll; toneAll; syllableAll; stringAll];

for i = 1:length(stimList)
    stimuli.(stimList{i}) = [];
end

for p = 1:length(maxslide)
    stimuli.(maxslide{p,2}) = [stimuli.(maxslide{p,2}), maxslide{p,1}];
end

count = 0;
histos = [];
for i = 1:length(stimList)
    count = count+1;
    p = histogram(stimuli.(stimList{i}), 'BinWidth', .005);
    histos{count, 1} = p.BinLimits(1);
    histos{count, 2} = p.BinLimits(2);
    histos{count, 3} = p.BinWidth;
    histos{count, 4} = p.Values;
    clear p
end

spacer = 15;
cmap = colormap('hsv');
ax1 = figure;

for i = 1:length(stimList)
    xvalues = histos{i,1}-histos{i,3}:histos{i,3}:histos{i,2}+histos{i,3};
    yvalues = [0,histos{i,4}, 0];
    if length(xvalues) < length(yvalues)
        xvalues = histos{i,1}-histos{i,3}:histos{i,3}:histos{i,2}+histos{i,3};
    elseif length(xvalues) > length(yvalues)
        yvalues(numel(xvalues)) = 0;
    end
    ax(i) = fill(xvalues, yvalues- (i*spacer), cmap(i*floor(length(cmap)/length(stimList)),:));
    text(stimnamespot, -(i*spacer), stimList{i}, 'HorizontalAlignment', 'left', 'Interpreter', 'none')
    hold on
end
line('XData', [0.1 0.1], 'YData', [-430 10], 'color', 'k', 'linewidth', 0.5)
line('XData', [-0.1 -0.1], 'YData', [-430 10], 'color', 'k', 'linewidth', 0.5)
line('XData', [0.6 0.6], 'YData', [-350 -340], 'color', 'k', 'linewidth', 1)
text(0.605, -345, '10 neurons')
title(titler)
xlim(xlimer)
set(gca, 'TickDir', 'out')
set(gca, 'FontName', 'Arial Narrow')
set(gca, 'fontsize', 8)
set(gca, 'ytick', [])
set(gca, 'xcolor', 'k')
set(gca, 'color', 'none')
set(gca, 'box', 'off')


