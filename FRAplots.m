% This script batches through FRA data saved in the structure 'neuron'.
% It automatically finds the frequencies and attenuations used.
% After calculating the FRA in free and held conditions, it is plotted and
% saved as a tiff file.
%
% Created by EHazlett 01/01/2018
%

window1 = [101, 300]; % window to calc response prestim = 100 poststim= 900
cd('C:\BLA paper\FRA images\')
mymap = [0,0,1
    0,0,0.75
    0,0,0.5
    0,0,0.25
    0,0,0
    0.25,0,0
    0.5,0,0
    0.75,0,0
    1,0,0];

for i = 1:length(neuron)
    %% FRA Free
    if isfield(neuron(i).PSTH_1msbins, 'FRA_free') % is there a free_FRA
        fraFree_freq = replace(fieldnames(neuron(i).PSTH_1msbins.FRA_free), 'Hz_', '');
        fraFree_freq = cellfun(@str2num, fraFree_freq); % find freq used in fra
        
        fraFree_atten = replace( ...
            fieldnames(neuron(i).PSTH_1msbins.FRA_free.(['Hz_', num2str(fraFree_freq(1))])), ...
            'dB_', ''); % Find attens used for lowest frequency in fra
        fraFree_atten = cellfun(@str2num, fraFree_atten);
        
        % Calculate mean response for each freq/ atten pair
        fraFree = zeros(length(fraFree_atten), length(fraFree_freq));
        for f = 1:length(fraFree_freq)
            for a = 1:length(fraFree_atten)
                psth = neuron(i).PSTH_1msbins.FRA_free.(['Hz_', num2str(fraFree_freq(f))]).(['dB_', num2str(fraFree_atten(a))]);
                [~, col] = find(isnan(psth));
                psth(:, unique(col)) = []; % drop reps with NaN
                psth(:, sum(psth) > max(neuron(i).OverallBG.free*5,50)) = []; % drop reps with more than 100 spikes in sweep.  Fixes bursting
                
                fraFree (a,f) = mean(sum(psth(window1(1):window1(2), 1:end-1)));
                clear psth
            end
        end
        neuron(i).PSTH.free = fraFree;
    else
    end
    
    %% FRA Held
    if isfield(neuron(i).PSTH_1msbins, 'FRA_held') % is there a free_FRA
        fraHeld_freq = replace(fieldnames(neuron(i).PSTH_1msbins.FRA_held), 'Hz_', '');
        fraHeld_freq = cellfun(@str2num, fraHeld_freq); % find freq used in fra
        
        fraHeld_atten = replace( ...
            fieldnames(neuron(i).PSTH_1msbins.FRA_held.(['Hz_', num2str(fraFree_freq(1))])), ...
            'dB_', ''); % Find attens used for lowest frequency in fra
        fraHeld_atten = cellfun(@str2num, fraHeld_atten);
        
        % Calculate mean response for each freq/ atten pair
        fraHeld = zeros(length(fraHeld_atten), length(fraHeld_freq));
        for f = 1:length(fraHeld_freq)
            for a = 1:length(fraHeld_atten)
                psth = neuron(i).PSTH_1msbins.FRA_held.(['Hz_', num2str(fraHeld_freq(f))]).(['dB_', num2str(fraHeld_atten(a))]);
                [~, col] = find(isnan(psth));
                psth(:, unique(col)) = []; % drop reps with NaN
                psth(:, sum(psth) > max(neuron(i).OverallBG.held*5,50)) = []; % drop reps with more than 100 spikes in sweep.  Fixes bursting
                
                fraHeld (a,f) = mean(sum(psth(window1(1):window1(2), 1:end-1)));
                clear psth
            end
        end
        neuron(i).PSTH.held = fraHeld;
    else
    end
    
    %% Plot FRAs
    figure;
    set(gcf,'position', [0, 0, 1250, 800])
    if exist('fraFree', 'var') == 1
        if any(isnan(fraFree))
            disp('nans idiot')
            return
        end
        % actual mean spikes per window
        ax(1) = subplot(2, 2, 1);
        imagesc([min(fraFree_freq), max(fraFree_freq)], ...
            [min(fraFree_atten), max(fraFree_atten)], ...
            fraFree)
        title(ax(1), [neuron(i).name, ' FRA free - Spike Count'])
        ylabel(ax(1), 'dB SPL')
        xlabel(ax(1), 'Frequency (kHz)')
        set(ax(1), 'TickLength',[0 0])
        set(ax(1), 'YTick', fliplr(fraFree_atten'))
        set(ax(1), 'YTickLabel', num2str(fraFree_atten))
        c = colorbar;
        c.Location = 'eastOutside';
        
        r = fraFree*(1000/(window1(2)-window1(1)+1));
        fraFree = log10((r + 20) ./ (neuron(i).OverallBG.free + 20));
        clear r
        
        ax(2) = subplot(2, 2, 3);
        imagesc([min(fraFree_freq), max(fraFree_freq)], ...
            [min(fraFree_atten), max(fraFree_atten)], ...
            fraFree)
        title(ax(2), [neuron(i).name, ' FRA free - RMI'])
        ylabel(ax(2), 'dB SPL')
        xlabel(ax(2), 'Frequency (kHz)')
        set(ax(2), 'TickLength',[0 0])
        set(ax(2), 'YTick', fliplr(fraFree_atten'))
        set(ax(2), 'YTickLabel', num2str(fraFree_atten))
        set(ax(2), 'CLim', [-1, 1])
        colormap(ax(2), mymap)
        c = colorbar;
        c.Location = 'eastOutside';
    end
    
    if exist('fraHeld', 'var') == 1
        if any(isnan(fraHeld))
            disp('nans idiot')
            return
        end
        ax(3) = subplot(2, 2, 2);
        imagesc([min(fraHeld_freq), max(fraHeld_freq)], ...
            [min(fraHeld_atten), max(fraHeld_atten)], ...
            fraHeld)
        title(ax(3), [neuron(i).name, ' FRA held - Spike Count'])
        ylabel(ax(3), 'dB SPL')
        xlabel(ax(3), 'Frequency (kHz)')
        set(ax(3), 'TickLength',[0 0])
        set(ax(3), 'YTick', fliplr(fraHeld_atten'))
        set(ax(3), 'YTickLabel', num2str(fraHeld_atten))
        c = colorbar;
        c.Location = 'eastOutside';
        
        r = fraHeld*(1000/(window1(2)-window1(1)+1));
        fraHeld = log10((r + 20) ./ (neuron(i).OverallBG.held + 20));
        clear r
        
        ax(4) = subplot(2, 2, 4);
        imagesc([min(fraHeld_freq), max(fraHeld_freq)], ...
            [min(fraHeld_atten), max(fraHeld_atten)], ...
            fraHeld)
        title(ax(4), [neuron(i).name, ' FRA held - RMI'])
        ylabel(ax(4), 'dB SPL')
        xlabel(ax(4), 'Frequency (kHz)')
        set(ax(4), 'TickLength',[0 0])
        set(ax(4), 'YTick', fliplr(fraHeld_atten'))
        set(ax(4), 'YTickLabel', num2str(fraHeld_atten))
        set(ax(4), 'CLim', [-1, 1])
        colormap(ax(4), mymap)
        c = colorbar;
        c.Location = 'eastOutside';

    end
    saveas(gca,[neuron(i).name, ' FRA'], 'tiff')
    close all
    clear fra*
end
