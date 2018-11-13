%% Find each test, stim, and atten combo for each neuron

% clearvars -except neuron

count = 0;
binSize = 20; %ms per bin for smaller psth
slide = 5; %ms of sliding window

categories = fieldnames(neuron.Sounds);
drop1 = contains(categories, 'Vocal');
categories(~drop1) = [];
% Batch through all sound categories
for i = 1:length(categories)
    plots = figure('units','normalized','outerposition',[0 0 1 1]);
    plots.Name = [neuron.UnitID, ' (', neuron.UnitType, ')', categories{i},  ' rasters and PSTHs' ];
    spikes = figure('units','normalized','outerposition',[0 0 1 1]);
    spikes.Name = [neuron.UnitID, ' (', neuron.UnitType, ')', categories{i}, ' spike overlays' ];
    
    stimuli = fieldnames(neuron.Sounds.(categories{i}));
    drop1 = contains(stimuli, 'Appease');
    drop2 = contains(stimuli, 'Biosonar');
    drop3 = contains(stimuli, 'LowAgg');
    stimuli(drop1|drop2|drop3) = []; % Drop attenuated tests
    
    % Batch through all stimuli
    for ii = 1:length(stimuli)
        conditions = fieldnames(neuron.Sounds.(categories{i}).(stimuli{ii}));
        
        % Batch through all recording conditions
        for iii = 1:length(conditions)
            presentationmodes = fieldnames(neuron.Sounds.(categories{i}).(stimuli{ii}).(conditions{iii}));
            drop1 = contains(presentationmodes, 'RLF');
            presentationmodes(drop1) = [];
            % Batch through all presentation modes
            for iiii = 1:length(presentationmodes)
                attenuations = fieldnames(neuron.Sounds.(categories{i}).(stimuli{ii}).(conditions{iii}).(presentationmodes{iiii}));
                drop1 = contains(attenuations, 'dB_80');
                attenuations(~drop1) = []; % Drop attenuated tests
                
                % Batch through all attenuation levels
                for v = 1:length(attenuations)
                    data.preStim = 110;%neuron.Sounds.(categories{i}).(stimuli{ii}).(conditions{iii}).(presentationmodes{iiii}).(attenuations{v}).preStim;
                    data.postStim = 890;%neuron.Sounds.(categories{i}).(stimuli{ii}).(conditions{iii}).(presentationmodes{iiii}).(attenuations{v}).postStim;
                    data.psth1ms.psth = neuron.Sounds.(categories{i}).(stimuli{ii}).(conditions{iii}).(presentationmodes{iiii}).(attenuations{v}).peth;
                    [~, col] = find(isnan(data.psth1ms.psth));
                    data.psth1ms.psth(:, unique(col)) = []; % drop reps with NaN
                    [data.psth1ms.bins, data.psth1ms.reps] = size(data.psth1ms.psth);
                    [data.rasterrow, data.raster] = find(data.psth1ms.psth);
                    
                    if data.psth1ms.reps < 30
                        clear data
                        continue
                    end
                    
                    bin=0;
                    for p = binSize:binSize:data.psth1ms.bins
                        bin = bin + 1;
                        data.psthBin.psth (bin, 1:data.psth1ms.reps) = sum(data.psth1ms.psth(p-binSize+1:p, :));
                    end
                    
                    bin = 0;
                    for p = (binSize/2):slide:data.psth1ms.bins-(binSize/2)
                        bin = bin + 1;
                        data.psthBinSlide.psth (bin, 1:data.psth1ms.reps) = sum(data.psth1ms.psth(p-(binSize/2)+1:p+(binSize/2), :));
                    end
                    clear p bin
                    
                    data.psthBin.meanRate = (mean(data.psthBin.psth, 2) / binSize) * 1000;
                    data.psthBinSlide.meanRate = (mean(data.psthBinSlide.psth, 2) / binSize) * 1000;
                    
                    %% Mean PSTH responsive bins
                    count = count+1;
                    heighth =max(data.psthBinSlide.meanRate)+10;
                    data.rasterspacer = heighth / data.psth1ms.reps;
                    
                    figure(plots)
                    ax(1) = subplot(length(stimuli), length(conditions)*length(presentationmodes), count);
                    plot(linspace(-data.preStim, data.postStim, length(data.psthBinSlide.meanRate)), data.psthBinSlide.meanRate', ...
                        'Color', [0.5 0.5 0.5], 'linewidth', 2)
                    hold on
                    scatter(data.rasterrow-data.preStim, data.raster*data.rasterspacer, 1, 'filled', 'k')
                    ylim([-2 heighth+2])
                    xlim([-(data.preStim+5) (data.postStim+5)])
                    title([stimuli{ii}, ' ', conditions{iii}, ' ', presentationmodes{iiii}, ' ', attenuations{v}], 'Interpreter', 'none')
                    set(gca, 'TickDir', 'out')
                    set(gca, 'FontName', 'Arial Narrow')
                    set(gca, 'fontsize', 8)
                    %         set(gca, 'ytick', [])
                    set(gca, 'xcolor', 'k')
%                     set(gca, 'color', 'none')
                    set(gca, 'box', 'off')
                    
                    %% Plot spike overlays
                   figure(spikes)
                   ax(2) = subplot(length(stimuli), length(conditions)*length(presentationmodes), count);
                   plot(neuron.Sounds.(categories{i}).(stimuli{ii}).(conditions{iii}).(presentationmodes{iiii}).(attenuations{v}).spikes.trace', 'Color', [0.5 0.5 0.5]);
                   hold on
                   plot(mean(neuron.Sounds.(categories{i}).(stimuli{ii}).(conditions{iii}).(presentationmodes{iiii}).(attenuations{v}).spikes.trace,1), ...
                       'k', 'LineWidth', 2)
                   title([stimuli{ii}, ' ', conditions{iii}, ' ', presentationmodes{iiii}, ' ', attenuations{v}], 'Interpreter', 'none')
                    axis tight
                   set(gca, 'FontName', 'Arial Narrow')
                    set(gca, 'fontsize', 8)
                    set(gca, 'ytick', [])
                    set(gca, 'xtick', [])
                    set(gca, 'color', 'none')
%                     set(gca, 'box', 'off')
                    clear data
                end
            end
        end
    end
end
%          saveas(gca,[neuron.name, ' raster_',num2str(tests{ii})], 'tiffn')
%         close all
% set(ax, 'YLim', [-2, heighth]);% max(scaler)])
clear ax scaler
