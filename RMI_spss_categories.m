background = [1, 100]; % window to calculate pre stim background discharge
window1 = [101, 150]; % window to calc early response prestim = 100 poststim= 900
window2 = [201, 500]; % window to calc late response window

Cats.tUSV = {'p100_1'; 'p100_4'; 'p100_5'; 'p100_6'; 'p100_7'; 'p100_8'; 'p100_10'};
Cats.stpUSV = {'p100_2'; 'p100_3'};
Cats.calls = {'p100_9'; 'p100_11'};


%% Find all tests
vne = [num2str(window1(1)-background(2)-1), 'to', num2str(window1(2)-background(2))];
vnl = [num2str(window2(1)-background(2)-1), 'to', num2str(window2(2)-background(2))];
usvAll = {'tUSV'; 'stpUSV'; 'calls'};

count = 1;
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
%% Run through data
N_dataset = length(neuron);
for i = 1:N_dataset
    tests = fieldnames(neuron(i).PSTH_1msbins);
    drop1 = contains(tests, 'FRA'); % don't run on FRA or ISG tests
    drop2 = contains(tests, 'ISG');
    drop3 = contains(tests, 'BBN');
    tests(drop1|drop2) = [];
    clear drop*
    if isempty(tests) == 1 % Dont continue if there's no tests left
        continue
    end
    count = count + 1;
    % Batch through all tests
    for ii = 1:length(tests)
        stim = fieldnames(neuron(i).PSTH_1msbins.(tests{ii}));
        % Batch through all stimuli
        for j = 1:length(usvAll)
            chunker = zeros(1000:1);
            for iii = 1:length(stim)
                if  any(contains(Cats.(usvAll{j}),stim{iii}))
                    atten = fieldnames(neuron(i).PSTH_1msbins.(tests{ii}).(stim{iii}));
                    %Batch through all attenuations
                    for iiii = 1:length(atten)
                        %% Analyze one tests
                        psth = neuron(i).PSTH_1msbins.(tests{ii}).(stim{iii}).(atten{iiii});
                        [~, col] = find(isnan(psth));
                        psth(:, unique(col)) = []; % drop reps with NaN
                        chunker = [chunker, psth];
                    end
                end
            end
            [reps, col] = size(chunker);
            if reps < 2
                continue
            end
            psth = chunker(:, 2:end);
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
            
            %% Add data to output
            if contains(tests{ii}, 'USV')
                col = find(strcmp(testsAll, strrep(tests{ii}, 'USV', usvAll{j})));
                output{count, 1} = neuron(i).name;
                output{count, col*2} = rmiEarly;
                output{count, col*2+1} = rmiLate;
            end
        end
    end
end


