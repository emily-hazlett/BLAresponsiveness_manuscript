clearvars -except maxslide
maxslideSMI = p;
bbnAll = {'BBN_30'};
toneAll = {'Hz_15000'; 'Hz_20000'; 'Hz_25000'; 'Hz_30000'; 'Hz_35000'; 'Hz_40000'};
syllableAll = {'Biosonar'; 'DFM_QCFl'; 'DFMl'; 'DFMl_QCFl_UFM'; 'DFMs'; 'QCF'; 'UFM'; 'rBNBl'; 'rBNBs'; 'sAFM'; 'sHFM'; 'sinFM'; 'torQCF'};
stringAll = {'App1_string'; 'App2_string'; 'High1_string'; 'High3_string'; 'Low3_string'; 'Med1_string'; 'Tone25_string'; 'search2_string'};
stimList = {'Allfreqs'; 'BBN_30ms'; 'HighAgg'; 'p100_9'; 'p100_11'; 'p100_2'; 'p100_3'; ...
    'p100_1'; 'p100_4'; 'p100_5'; 'p100_6'; 'p100_7'; 'p100_8'; ...
    'p100_10'; };
for i = 1:length(stimList)
    eval([stimList{i},' = [];']);
end

for p = 1:length(maxslideSMI)
    i = maxslideSMI{p,2};
    switch i
        case 'Allfreqs'
            Allfreqs = [Allfreqs, maxslideSMI{p,1}];
        case 'BBN_30ms'
            BBN_30ms = [BBN_30ms, maxslideSMI{p,1}];
        case 'HighAgg'
            HighAgg = [HighAgg,maxslideSMI{p,1}];
        case 'p100_1'
            p100_1 = [p100_1, maxslideSMI{p,1}];
        case 'p100_2'
            p100_2 = [p100_2, maxslideSMI{p,1}];
        case 'p100_3'
            p100_3 = [p100_3, maxslideSMI{p,1}];
        case 'p100_4'
            p100_4 = [p100_4, maxslideSMI{p,1}];
        case 'p100_5'
            p100_5 = [p100_5, maxslideSMI{p,1}];
        case 'p100_6'
            p100_6 = [p100_6, maxslideSMI{p,1}];
        case 'p100_7'
            p100_7 = [p100_7, maxslideSMI{p,1}];
        case 'p100_8'
            p100_8 = [p100_8, maxslideSMI{p,1}];
        case 'p100_9'
            p100_9 = [p100_9, maxslideSMI{p,1}];
        case 'p100_10'
            p100_10 = [p100_10, maxslideSMI{p,1}];
        case 'p100_11'
            p100_11 = [p100_11, maxslideSMI{p,1}];
    end
end

count = 0;
histos = [];
for i = 1:length(stimList)
    count = count+1;
    eval(['p = histogram(', stimList{i}, ', "BinWidth", .01);']);
    histos{count, 1} = p.BinLimits(1);
    histos{count, 2} = p.BinLimits(2);
    histos{count, 3} = p.BinWidth;
    histos{count, 4} = p.Values;
    clear p
end

spacer = 20;
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
    hold on
end
line('XData', [0.15 0.15], 'YData', [-300 50], 'color', 'k', 'linewidth', 0.5)
line('XData', [1.5 1.5], 'YData', [-250 -240], 'color', 'k', 'linewidth', 1)
xlim([-0.5, 2])
set(gca, 'TickDir', 'out')
set(gca, 'FontName', 'Arial Narrow')
set(gca, 'fontsize', 8)
set(gca, 'ytick', [])
set(gca, 'xcolor', 'k')
set(gca, 'color', 'none')
set(gca, 'box', 'off')


