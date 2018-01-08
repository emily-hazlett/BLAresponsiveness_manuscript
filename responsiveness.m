background = [1, 100]; % window to calculate pre stim background discharge
window1 = [101, 150]; % window to calc early response prestim = 100 poststim= 900
window2 = [156, 350]; % window to calc late response window
binSize = 10; %ms per bin for smaller psth
N_dataset = length(neuron);
% count = 0;
mymap = [1 1 1; 0 0 0; 1 0 0];

%% Recalculate windows based on bin size
background = ceil(background/binSize);
window1 = ceil(window1/binSize);
window2 = ceil(window2/binSize);

%% Find all tests
vne = [num2str(window1(1)-background(2)-1), 'to', num2str(window1(2)-background(2))];
vnl = [num2str(window2(1)-background(2)-1), 'to', num2str(window2(2)-background(2))];

testsAll = {'BBN62_free1';'BBN62_free2';'BBN62_held1';'BBN62_held2'; 'BBN30_free1';'BBN30_free2';'BBN30_held1';'BBN30_held2';};
count = length(testsAll)+1;

usvAll = {'Appease';'Biosonar';'HighAgg';'LowAgg';'p100_1';'p100_10';'p100_11';'p100_2';'p100_3';'p100_4';'p100_5';'p100_6';'p100_7';'p100_8';'p100_9'};
for i = 1:length(usvAll)
    testsAll{count, 1} = [usvAll{i}, '_rand_free1'];
    count = count + 1;
end
for i = 1:length(usvAll)
    testsAll{count, 1} = [usvAll{i}, '_rand_free2'];
    count = count + 1;
end
for i = 1:length(usvAll)
    testsAll{count, 1} = [usvAll{i}, '_rand_held1'];
    count = count + 1;
end
for i = 1:length(usvAll)
    testsAll{count, 1} = [usvAll{i}, '_rand_held2'];
    count = count + 1;
end
for i = 1:length(usvAll)
    testsAll{count, 1} = [usvAll{i}, '_rep_free'];
    count = count + 1;
end

clear output
output{1, 1} = 'Neuron';
count = 2;
for i = 1:length(testsAll)
    output{1, count} = [testsAll{i}, '_RMI', vne];
    output{1, count+1} = [testsAll{i}, '_RMI', vnl];
    count = count+2;
end
count = 1;

%% Find each test, stim, and atten combo for each neuron
for i = 1:N_dataset
    tests = fieldnames(neuron(i).PSTH_1msbins);
    drop1 = contains(tests, 'FRA'); % don't run on FRA or ISG tests
    drop2 = contains(tests, 'ISG');
    drop3 = contains(tests, 'RLF');
    tests(drop1|drop2|drop3) = [];
    clear drop*
    if isempty(tests) == 1 % Dont continue if there's no tests left
        continue
    end
    % Batch through all tests
    for ii = 1:length(tests)
        % Format output table
        output{1, 1} = 'Neuron';
        output{1, 2} = 'Test';
        output{1, 3} = 'Stim';
        output{1, 4} = 'Intensity';
        output{1, 5} = ['RMI for ', num2str((window1(1)-background(2)-1)*binSize), '-', num2str((window1(2)-background(2))*binSize), 'ms'];
        output{1, 6} = ['RMI for ', num2str((window2(1)-background(2)-1)*binSize), '-', num2str((window2(2)-background(2))*binSize), 'ms'];
        output{1, 7} = 'Responsive in early window';
        output{1, 8} = 'Responsive in late window';
        output{1, 9} = 'Responsive in either window';
        output{1, 10} = 'Prestim BG (M)';
        output{1, 11} = 'Prestim BG (SD)';
        output{1, 12} = 'Early Response (M)';
        output{1, 13} = 'Early Response (SD)';
        output{1, 14} = 'Late Response (M)';
        output{1, 15} = 'Late Response (SD)';
        output{1, 16} = ['PSTH_', num2str(binSize),'msM'];
        output{1, 17} = ['PSTH_', num2str(binSize),'msSD'];
        output{1, 18} = ['Responsive_', num2str(binSize),'ms'];
        count = 1;
        stim = fieldnames(neuron(i).PSTH_1msbins.(tests{ii}));
        % Batch through all stimuli
        for iii = 1:length(stim)
            atten = fieldnames(neuron(i).PSTH_1msbins.(tests{ii}).(stim{iii}));
            %Batch through all attenuations
            for iiii = 1:length(atten)
                count = count+1;
                %% Bin PSTH
                psth = neuron(i).PSTH_1msbins.(tests{ii}).(stim{iii}).(atten{iiii});
                [~, col] = find(isnan(psth));
                psth(:, unique(col)) = []; % drop reps with NaN
                [bins, reps] = size(psth);
                
                bin = 0;
                for p = binSize:binSize:bins
                    bin = bin + 1;
                    psthBin (bin, 1:reps) = sum(psth(p-binSize+1:p, :));
                end
                
                %% Spiking in windows
                psthBinM = mean(psthBin, 2);
                psthBinSD = std(psthBin, 0, 2);
                
                baseline = sum(psth(background(1):background(2),:));
                baselineHz = baseline / (background(2)-baseline(1)+1)*1000;
                baselineHzM = mean(baselineHz);
                baselineHzSD = std(baselineHz);
                
                responseEarly = sum(psth(window1(1):window1(2),:));
                responseEarlyHz = responseEarly / (window1(2)-window1(1)+1)*1000;
                responseEarlyHzM = mean(responseEarlyHz);
                responseEarlyHzSD = std(responseEarlyHz);
                
                responseLate = sum(psth(window2(1):window2(2),:));
                responseLateHz = responseLate / (window2(2)-window2(1)+1)*1000;
                responseLateHzM = mean(responseLateHz);
                responseLateHzSD = std(responseLateHz);
                
                %% Find responsive bins
                responsiveEarly = any(psthBinM(window1(1):window1(2), :) > (baselineHzM + 2*baselineHzSD)); % responsive bin in early window
                
                responsiveLate = psthBinM(window2(1):window2(2), :) > (baselineHzM + 2*baselineHzSD);
                conBins = 2; % Number of consecutive bins needed for late window to be responsive
                for p = 1:length(responsiveLate)-1
                    pp(p) = sum(responsiveLate(p:p+conBins-1));
                end
                responsiveLate = any(pp >= conBins);
                responsive = responsiveEarly | responsiveLate;
                clear pp
                
                %% RMI
                rmiEarly = (responseEarlyHzM - baselineHzM) / (responseEarlyHzM + baselineHzM + 0.00000001);
                rmiLate = (responseLateHzM - baselineHzM) / (responseLateHzM + baselineHzM + 0.00000001);
                
                %% Mean PSTH responsive bins
                %                 if reps > 75
                %                     count = count + 1;
                baseline = sum(psth(background(1):background(2),:));
                baselineM = mean(baseline); % Spikes per bin instead of Hz
                baselineSD = std(baseline);
                
                response = zeros(size(psthBinM));
                response((psthBinM) > (baselineM + 2*baselineSD)) = 1;
                response((psthBinM) < (baselineM - 2*baselineSD)) = -1;
                %                     responseAll(count, 1:length(response)) = response';
                %                 else
                %                     response = NaN;
                %                 end
                
                
                %% Save summary
                output{count, 1} = neuron(i).name;
                output{count, 2} = tests{ii};
                output{count, 3} = stim{iii};
                output{count, 4} = atten{iiii};
                output{count, 5} = rmiEarly;
                output{count, 6} = rmiLate;
                output{count, 7} = responsiveEarly;
                output{count, 8} = responsiveLate;
                output{count, 9} = responsive;
                output{count, 10} = baselineHzM;
                output{count, 11} = baselineHzSD;
                output{count, 12} = responseEarlyHzM;
                output{count, 13} = responseEarlyHzSD;
                output{count, 14} = responseLateHzM;
                output{count, 15} = responseLateHzSD;
                output{count, 16} = psthBinM;
                output{count, 17} = psthBinSD;
                output{count, 18} = response;
                
                clear respons* psth* baseline*
            end
        end
        %         Save summary output to structure
        neuron(i).summary.(tests{ii}) = output;
        clear output
        clear count
        %         if count == 0
        %             continue
        %         end
        %         figure
        %         ax = imagesc(responseAll);
        %         colormap(mymap)
        %         caxis([-1, 1])
        %         title([neuron(i).name, ' ', tests{ii}, ' all stim'])
        %         xlabel('Bins')
        %         count = 0;
        %         clear responseAll
        
    end
end
