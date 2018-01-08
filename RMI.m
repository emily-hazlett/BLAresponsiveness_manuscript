% This script calculates the rmi and responsiveness of BLA neurons in
% 2 windows to single presentation of sounds.  It batches through all
% tests containined in the neuron structure, and saves a summary output.
%
% Created by EHazlett 01-02-2018
%

background = [1, 100]; % window to calculate pre stim background discharge
window1 = [101, 150]; % window to calc early response prestim = 100 poststim= 900
window2 = [201, 500]; % window to calc late response window
N_dataset = length(neuron);
count = 1;

%% Find each test, stim, and atten combo for each neuron
for i = 1:N_dataset
    tests = fieldnames(neuron(i).PSTH_1msbins);
    drop1 = contains(tests, 'FRA'); % don't run on FRA or ISG tests
    drop2 = contains(tests, 'ISG');
    tests(drop1|drop2) = [];
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
        output{1, 5} = ['RMI for ', num2str(window1(1)-background(2)-1), '-', num2str(window1(2)-background(2)), 'ms'];
        output{1, 6} = ['RMI for ', num2str(window2(1)-background(2)-1), '-', num2str(window2(2)-background(2)), 'ms'];
        output{1, 7} = 'Responsive in early window';
        output{1, 8} = 'Responsive in late window';
        output{1, 9} = 'Responsive in either window';
        output{1, 10} = 'Prestim BG (M)';
        output{1, 11} = 'Prestim BG (SD)';
        output{1, 12} = 'Early Response (M)';
        output{1, 13} = 'Early Response (SD)';
        output{1, 14} = 'Late Response (M)';
        output{1, 15} = 'Late Response (SD)';
        
%         count = 1;
        stim = fieldnames(neuron(i).PSTH_1msbins.(tests{ii}));
        % Batch through all stimuli
        for iii = 1:length(stim)
            atten = fieldnames(neuron(i).PSTH_1msbins.(tests{ii}).(stim{iii}));
            %Batch through all attenuations
            for iiii = 1:length(atten)
                %% Analyze one tests
                psth = neuron(i).PSTH_1msbins.(tests{ii}).(stim{iii}).(atten{iiii});
                [~, col] = find(isnan(psth));
                psth(:, unique(col)) = []; % drop reps with NaN
                [bins, reps] = size(psth);
                
                baseline = psth(background(1):background(2),:);
                baselineHz = sum(baseline) / (background(2)-baseline(1)+1)*1000;
                baselineHzM = mean(baselineHz);
                baselineHzSD = std(baselineHz);
                
                responseEarly = psth(window1(1):window1(2),:);
                responseEarlyHz = sum(responseEarly) / (window1(2)-window1(1)+1)*1000;
                responseEarlyHzM = mean(responseEarlyHz);
                responseEarlyHzSD = std(responseEarlyHz);
                
                responseLate = psth(window2(1):window2(2),:);
                responseLateHz = sum(responseLate) / (window2(2)-window2(1)+1)*1000;
                responseLateHzM = mean(responseLateHz);
                responseLateHzSD = std(responseLateHz);
                %% Responsive
                responsiveEarly = (responseEarlyHzM - 2*responseEarlyHzSD) > (baselineHzM + 2*baselineHzSD);
                responsiveLate = (responseLateHzM - 2*responseLateHzSD) > (baselineHzM + 2*baselineHzSD);
                responsive = responsiveEarly | responsiveLate;

                rmiEarly = (responseEarlyHzM - baselineHzM) / (responseEarlyHzM + baselineHzM + 0.00000001);
                rmiLate = (responseLateHzM - baselineHzM) / (responseLateHzM + baselineHzM + 0.00000001);
                
                %% Save summary
                count = count+1;
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
                clear rmi* respons* psth reps bins col *Hz* 
            end
        end
        % Save summary output to structure
%         neuron(i).summary.(tests{ii}) = output;
%         clear output
%         clear count
    end
end