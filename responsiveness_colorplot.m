clearvars -except neuron

window0 = [1, 100]; % window to calculate pre stim background discharge
window1 = [1, 50]; % early window
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
for i = 1:length(neuron)
    tests = fieldnames(neuron(i).PSTH_1msbins);
    drop1 = contains(tests, 'FRA'); % don't run on FRA or ISG tests
    drop2 = contains(tests, 'ISG');
    drop3 = contains(tests, 'RLF');
    drop4 = contains(tests, 'USV');
    tests(drop1|drop2|drop3|drop4) = [];
    clear drop*
    if isempty(tests) == 1 % Dont continue if there's no tests left
        continue
    end
    % Batch through all tests
    for ii = 1:length(tests)
        stim = fieldnames(neuron(i).PSTH_1msbins.(tests{ii}));
        stim = fieldnames(neuron(i).PSTH_1msbins.(tests{ii}));
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
%             if strcmp(stim{iii}, 'p100_6') == 0
%                 continue
%             end
            atten = fieldnames(neuron(i).PSTH_1msbins.(tests{ii}).(stim{iii}));
            %Batch through all attenuations
            for iiii = 1:length(atten)
                %% Bin PSTH
                psth = neuron(i).PSTH_1msbins.(tests{ii}).(stim{iii}).(atten{iiii});
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
                
%                 ax(1) = subplot(3, 4, iii);
%                 imagesc(psth')
%                 set(ax(1), 'CLim', [0, 1])
%                 colormap([1 1 1; 0 0 0])
%                 title([neuron(i).name, '-',strrep(tests{ii}, 'USV', stim{iii})], 'Interpreter', 'none')
                
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
%                 lateHzM = mean(late) / (window2(2)-window2(1)+1)) * 1000;
                
                minner = baselineHzM - 3;
                maxxer = baselineHzM + 5;
                
                %                 response = (psthBinSlideHzM - baselineHzM) ./ (psthBinSlideHzM + baselineHzM + 0.01);
                response = zeros(size(psthBinHzM));
                response(psthBinHzM < minner) = -1;
                response(psthBinHzM > maxxer) = 1; % min of 3 spikes over all the reps to be excited
                %
%                 ax(1) = subplot(1,2,1);
%                 plot(psthBinSlideM, 'k', 'linewidth', 2)
%                 hold on
%                 plot(psthBinSlideM+psthBinSlideSD)
%                 plot(psthBinSlideM-psthBinSlideSD)
%                 plot(repmat(baselineHzM, 1, numel(psthBinHzM)), 'y')
%                 plot(repmat(minner, 1, numel(psthBinSlideM)), 'b--')
%                 plot(repmat(maxxer, 1, numel(psthBinSlideM)), 'r--')
%                 axis tight
%                 fill([window1b(1)-.5, window1b(2)+.5, window1b(2)+.5, window1b(1)-.5], ...
%                     [maxxer, maxxer, minner, minner], [0.5 0.5 0.5], ...
%                     'EdgeColor', 'none', 'FaceAlpha', 0.1)
%                 fill([window2b(1)-.5, window2b(2)+.5, window2b(2)+.5, window2b(1)-.5], ...
%                     [maxxer, maxxer, minner, minner], [0.5 0.5 0.5], ...
%                     'EdgeColor', 'none', 'FaceAlpha', 0.1)
%                 title(['Just binned (', stim{iii}, ')'])
%                 hold off
%                 
%                 ax = subplot(3, 4, iii);
%                 plot(psthBinSlideHzM, 'k', 'linewidth', 2)
%                 hold on
% %                 plot(psthBinSlideHzM+psthBinSlideHzSD, 'r')
% %                 plot(psthBinSlideHzM-psthBinSlideHzSD, 'b')
%                 plot(repmat(baselineHzM, 1, numel(psthBinSlideHzM)), 'y')
%                 plot(repmat(minner, 1, numel(psthBinSlideHzM)), 'b--')
%                 plot(repmat(maxxer, 1, numel(psthBinSlideHzM)), 'r--')
%                 axis tight
%                 fill([window1s(1)-.5, window1s(2)+.5, window1s(2)+.5, window1s(1)-.5], ...
%                     [maxxer, maxxer, minner, minner], [0.5 0.5 0.5], ...
%                     'EdgeColor', 'none', 'FaceAlpha', 0.1)
%                 fill([window2s(1)-.5, window2s(2)+.5, window2s(2)+.5, window2s(1)-.5], ...
%                     [maxxer, maxxer, minner, minner], [0.5 0.5 0.5], ...
%                     'EdgeColor', 'none', 'FaceAlpha', 0.1)
%                 title([neuron(i).name, '-',strrep(tests{ii}, 'USV', stim{iii})], 'Interpreter', 'none')
%                 hold off
% %                 pause(3)
%                 
                %% Save summary
                count = count+1;
                output{count, 1} = neuron(i).name;
                output{count, 2} = tests{ii};
                output{count, 3} = stim{iii};
                output{count, 4} = '';
                output{count, 5} = '';
                output{count, 6} = '';
                output{count, 7} = '';
                for v = 1:length(response)
                    output{count, v+8} = response(v);
                end
                
                clear respons* psth* baseline* col bg
            end
        end
%          saveas(gca,[neuron(i).name, ' raster_',num2str(tests{ii})], 'tiffn')
        close all
    end
end
