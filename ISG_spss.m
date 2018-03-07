% This script is for calculating measures of responsiveness and
% Outputting them so they can be imported to spss.
% Responsive measures include RMI and bins above background in windows.
%
% Created by EHazlett 01-03-2018

clearvars -except neuron

window0a = [1, 100]; % window to calculate pre stim background discharge
window0b = [401, 500];
window1 = [1, 50]; % window to calc early response prestim = 100 poststim= 900
window2 = [501, 550]; % window to calc late response window

slide = 5; %ms of sliding window
binSize = 20; %ms per bin for smaller psth
conBins = 3;
N_dataset = length(neuron);

%% load dataset if necessary
if exist('neuron', 'var') == 0
    load('BLA_paper_dataset.mat')
end

%% Recalculate windows based on bin size
window1 = window1 + 100;
window2 = window2 + 100;
window0b = window0b + 100;

%% Find all tests
testsAll = {'ISG500_BBN30_free1';'ISG500_BBN30_free2';'ISG500_BBN30_held1';'ISG500_BBN30_held2'; 'ISG500_BBN62_free1';'ISG500_BBN62_free2';'ISG500_BBN62_held1';'ISG500_BBN62_held2'};

clear output
output{1, 1} = 'Neuron';
count = 2;
for i = 1:length(testsAll)
    output{1, count} = [testsAll{i}, '_sound1_responsive'];
    output{1, count+1} = [testsAll{i}, '_sound1_baseline'];
    output{1, count+2} = [testsAll{i}, '_sound2_baseline'];
    output{1, count+3} = [testsAll{i}, '_sound1_response'];
    output{1, count+4} = [testsAll{i}, '_sound2_response'];
    count = count+4;
end
count = 2;

%% Find each test, stim, and atten combo for each neuron
for i = 1:N_dataset
    tests = fieldnames(neuron(i).PSTH_1msbins);
    drop1 = contains(tests, 'ISG'); % don't run on FRA or ISG tests
    tests(~drop1) = [];
    clear drop*
    if isempty(tests) == 1 % Dont continue if there's no tests left
        continue
    end
    % Batch through all tests
    for ii = 1:length(tests)
        stim = fieldnames(neuron(i).PSTH_1msbins.(tests{ii}));
        % Batch through all stimuli
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
                
                %% Spiking in windows
                bg_sound1 = reshape(psth(window0a(1):window0a(2),:), 1, numel(psth(window0a(1):window0a(2),:)));
                bg_sound2 = reshape(psth(window0b(1):window0b(2),:), 1, numel(psth(window0a(1):window0a(2),:)));
                sound1 = reshape(psth(window1(1):window1(2),:), 1, numel(psth(window1(1):window1(2),:)));
                sound2 = reshape(psth(window2(1):window2(2),:), 1, numel(psth(window2(1):window2(2),:)));
                
                sound1_baselineHz = mean(bg_sound1) * 1000; %spikes/bin * bin/seconds = spikes/ second
                sound2_baselineHz = mean(bg_sound2) * 1000;
                sound1_responseHz = mean(sound1) * 1000;
                sound2_responseHz = mean(sound2) * 1000;
                
                %responsive
                responsive = log10((sound1_responseHz + 20)/(sound1_baselineHz + 20));
                s1_resp = responsive >= 0.1;
                
                %% Save summary
                col = find(strcmp(testsAll, tests{ii}));
                
                output{count, 1} = neuron(i).name;
                output{count, col*4 -3 +1} = s1_resp;
                output{count, col*4 -3 +1} = sound1_baselineHz;
                output{count, col*4 -2 +1} = sound2_baselineHz;
                output{count, col*4 -1 +1} = sound1_responseHz;
                output{count, col*4 -0 +1} = sound2_responseHz;
                
                clear respons* psth* baseline* col
            end
        end
    end
    count = count + 1;
end