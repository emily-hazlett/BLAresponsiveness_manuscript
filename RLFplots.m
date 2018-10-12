clearvars -except neuron*

window0 = [1, 100]; % window to calculate pre stim background discharge
window1 = [1, 200]; % early window
window2 = [56, 200]; % late window
binSize = 20; %ms per bin for smaller psth
slide = 5; %ms of sliding window

%% Recalculate windows based on bin size
window1 = window1 + 100;
window2 = window2 + 100;

window1s = [ceil(window1(1)/ slide), ceil(((window1(2)-binSize)/slide))+1];
window2s = [ceil(window2(1)/ slide), ceil(((window2(2)-binSize)/slide))+1];

%% format output
output = cell(1, (1000/binSize)+3);
output{1, 1} = 'Neuron';
output{1, 2} = 'Test';
output{1, 3} = 'Stim';
output{1, 4} = 'early';
output{1, 5} = 'late';
output{1, 6} = 'total';
output{1, 7} = 'suppressed';
output{1, 8} = ['Responsive_', num2str(binSize),'ms'];
count = 1;

%% Find each test, stim, and atten combo for each neuron
for i = 2 %24% 85 %56%85 % 1:length(neuron)
    tests = fieldnames(neuronselect(i).PSTH_1msbins);
    drop1 = contains(tests, 'USV'); % don't run on FRA or ISG tests
    drop2 = contains(tests, 'RLF');
    drop3 = contains(tests, 'ISG');
    tests(~drop2|drop3|drop1) = [];
    clear drop*
    if isempty(tests) == 1 % Dont continue if there's no tests left
        continue
    end
    % Batch through all tests
    for ii = 1:length(tests)
        stim = fieldnames(neuronselect(i).PSTH_1msbins.(tests{ii}));
        drop1 = contains(stim, 'Appease'); % don't run these stim
        drop2 = contains(stim, 'LowAgg');
        drop3 = contains(stim, 'Biosonar');
        stim(drop1|drop2|drop3) = [];
        clear drop*
        if isempty(stim) == 1 % Dont continue if there's no stim left
            continue
        end
        % Batch through all stimuli
        figure('units','normalized','outerposition',[0 0 1 1])
        for iii = 1:length(stim)
            atten = fieldnames(neuronselect(i).PSTH_1msbins.(tests{ii}).(stim{iii}));
            %Batch through all attenuations
            for iiii = 1:length(atten)
                %% Bin PSTH
                psth = neuronselect(i).PSTH_1msbins.(tests{ii}).(stim{iii}).(atten{iiii});
                [~, col] = find(isnan(psth));
                psth(:, unique(col)) = []; % drop reps with NaN
                [bins, reps] = size(psth);
                
                if reps < 30
                    clear psth col bins reps
                    continue
                end
                
                bin=0;
                for p = binSize:binSize:bins
                    bin = bin + 1;
                    psthBin (bin, 1:reps) = sum(psth(p-binSize+1:p, :));
                end
                
                bin = 0;
                for p = (binSize/2):slide:bins-(binSize/2)
                    bin = bin + 1;
                    psthBinSlide (bin, 1:reps) = sum(psth(p-(binSize/2)+1:p+(binSize/2), :));
                end
                clear p bin
                psthBinHzM = (mean(psthBin, 2) / binSize) * 1000;
                psthBinSlideHzM = (mean(psthBinSlide, 2) / binSize) * 1000;
                scaler(iiii) = max(psthBinSlideHzM);
            end
            
            %% Plot
            for iiii = 1:length(atten)
                spacer = max(scaler) / reps;

                psth = neuronselect(i).PSTH_1msbins.(tests{ii}).(stim{iii}).(atten{iiii});
                [~, col] = find(isnan(psth));
                psth(:, unique(col)) = []; % drop reps with NaN
                [bins, reps] = size(psth);
                
                if reps < 30
                    clear psth col bins reps
                    continue
                end
                
                bin=0;
                for p = binSize:binSize:bins
                    bin = bin + 1;
                    psthBin (bin, 1:reps) = sum(psth(p-binSize+1:p, :));
                end
                
                bin = 0;
                for p = (binSize/2):slide:bins-(binSize/2)
                    bin = bin + 1;
                    psthBinSlide (bin, 1:reps) = sum(psth(p-(binSize/2)+1:p+(binSize/2), :));
                end
                clear p bin
                
                %% Mean PSTH responsive bins
                bg = reshape(psth(window0(1):window0(2),:), 1, numel(psth(window0(1):window0(2),:)));
                early = reshape(psth(window1(1):window1(2),:), 1, numel(psth(window1(1):window1(2),:)));
                late = reshape(psth(window2(1):window2(2),:), 1, numel(psth(window2(1):window2(2),:)));
                
                psthBinHzM = (mean(psthBin, 2) / binSize) * 1000;
                
                psthBinSlideHzM = (mean(psthBinSlide, 2) / binSize) * 1000;
                psthBinSlideHzSD = (std(psthBinSlide, 0, 2) / binSize) * 1000;
                baselineHzM = mean(bg) * 1000; %spikes/bin * bin/seconds = spikes/ second
                baselineHzSD = std(bg) * 1000;
                earlyHzM = mean(early) * 1000;
                lateHzM = mean(late) * 1000;
                
                [row, col] = find(psth);
                ax(iiii) = subplot(length(atten), 1, iiii);
                fill([0, 200, 200, 0], [0, 0, max(scaler)+5, max(scaler)+5], [0.9 0.9 0.9])
                hold on
                plot(linspace(-100, 900, length(psthBinSlideHzM)), psthBinSlideHzM', 'k', 'linewidth', 2)
                scatter(row-100, col*spacer, 1, [0.3 0.3 0.3], 'filled')
                xlim([-110 910])
                title([neuronselect(i).name, '-',strrep(tests{ii}, 'USV', stim{iii}), ' atten', atten{iiii}], 'Interpreter', 'none')
                clear col
                
                
                
                clear respons* psth* baseline* col bg
            end
        end
        %          saveas(gca,[neuronselect(i).name, ' raster_',num2str(tests{ii})], 'tiffn')
        %         close all
        set(ax, 'YLim', [-0.5, max(scaler)+5])
        set(ax, 'TickDir', 'out')
        set(ax, 'FontName', 'Arial Narrow')
        set(ax, 'fontsize', 8)
        set(ax, 'xcolor', 'k')
        set(ax, 'ycolor', 'k')
        set(ax, 'color', 'none')
        set(ax, 'box', 'off')
%         clear ax scaler
    end
end