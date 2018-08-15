clearvars -except neuron
cd('C:\BLA paper\RLF\')


window0 = [1, 100]; % window to calculate pre stim background discharge
window1 = [1, 50]; % early window
window2 = [56, 200]; % late window
binSize = 20; %ms per bin for smaller psth
slide = 5; %ms of sliding window
conBins = 3;
c = {'k', 'b', 'g', 'y'};

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
    drop1 = contains(tests, 'RLF'); % don't run on FRA or ISG tests
    drop2 = contains(tests, 'free2');
    tests(drop2|~drop1) = [];
    clear drop*
    if isempty(tests) == 1 % Dont continue if there's no tests left
        continue
    end
    % Batch through all tests
    for ii = 1:length(tests)
        stim = fieldnames(neuron(i).PSTH_1msbins.(tests{ii}));
        % Batch through all stimuli
        figure('units','normalized','outerposition',[0 0 1 1])
        for iii = 1:length(stim)
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
                
                %% Responsive bins
                response = zeros(size(psthBinSlideHzM));
                response(psthBinSlideHzM < (baselineHzM - 3)) = -1; % 3 Hz below baseline firing rate
                response(psthBinSlideHzM > (baselineHzM + 5)) = 1; % baseline + 5 Hz
                
                % Are any bins excited or suppressed in the early window?
                responsiveEarly = any(response(window1s(1):window1s(2)) ~= 0);
                
                % Are enough consecutive bins excited in the late window?
                responsiveLate1 = response(window2s(1):window2s(2)) == 1;
                for pp = 1:length(responsiveLate1)-conBins+1
                    ppp(pp) = sum(responsiveLate1(pp:pp+conBins-1));
                end
                responsiveLate1 = any(ppp >= conBins);
                
                responsiveLate2 = response(window2s(1):window2s(2)) == -1;
                for pp = 1:length(responsiveLate2)-conBins+1
                    ppp(pp) = sum(responsiveLate2(pp:pp+conBins-1));
                end
                responsiveLate2 = any(ppp >= conBins);
                responsiveLate = responsiveLate1 | responsiveLate2;
                clear pp ppp
                
                %% plot
                subplot(4, 2, iiii)
                imagesc(psth')
                colormap([1 1 1; 0 0 0])
                title([atten{iiii}, ': responsive early = ' num2str(responsiveEarly), ' responsive late = ' num2str(responsiveLate)], 'Interpreter', 'none')
                
                ax(1) = subplot(4, 2, 5:8);
                plot(psthBinSlideHzM, c{iiii}, 'linewidth', 2);
                hold on
                axis tight
                
                
%                 %% Save summary
%                 count = count+1;
%                 output{count, 1} = neuron(i).name;
%                 output{count, 2} = tests{ii};
%                 output{count, 3} = stim{iii};
%                 output{count, 4} = '';
%                 output{count, 5} = '';
%                 output{count, 6} = '';
%                 output{count, 7} = '';
%                 for v = 1:length(response)
%                     output{count, v+8} = response(v);
%                 end
%                 
%                 clear respons* psth* baseline* col bg
            end
            title([neuron(i).name, '-',tests{ii}], 'Interpreter', 'none')
            hold off
%             pause (3)
            saveas(gca,[neuron(i).name, '_',tests{ii}], 'tiffn')
            close all
            clear psth* bg early* late* atten
        end
%          
        close all
    end
end
