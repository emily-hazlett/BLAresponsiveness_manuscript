% This script batches through FRA data saved in the structure 'neuron'.
% It automatically finds the frequencies and attenuations used.
% After calculating the FRA in free and held conditions, it is plotted and
% saved as a tiff file.
%
% Created by EHazlett 01/01/2018
%

window = [100, 700]; % window to calc response prestim = 100 poststim= 900
sweepLength = 1000;
clims = [0.05, 0.95];
% colorScale = [0, 3]; % set color scale from 0-2 spikes/second
N_dataset = length(neuron);
for i = 1:N_dataset
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
                m = trimmean(sum(psth(window(1):window(2), :)), 1, 'floor');
                s = std(sum(psth(window(1):window(2), :))) + 0.0001;
                fraFree (a,f) = m; %/s;
                %                 imagesc(psth')
                %                 hold on
                %                 title([neuron(i).name, 'Hz_', num2str(fraFree_freq(f)), ' ', num2str(fraFree_atten(a))])
                clear psth* s m
            end
        end
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
                m = trimmean(sum(psth(window(1):window(2), :)), 5, 'floor');
                s = std(sum(psth(window(1):window(2), :))) + 0.0001;
                fraHeld (a,f) = m; %/s;
                %                 imagesc(psth')
                %                 hold on
                %                 title([neuron(i).name, 'Hz_', num2str(fraFree_freq(f)), ' ', num2str(fraFree_atten(a))])
                clear psth* s m
            end
        end
    else
    end
    
    
    %% Plot FRAs
    figure;
    set(gcf,'position', [0, 0, 1250, 375])
    if exist('fraFree', 'var') == 1
        if any(isnan(fraFree))
            disp('nans idiot')
            return
        end
        % actual mean spikes per window
        colorScale = quantile(reshape(fraFree, 1, numel(fraFree)), clims);
        colorScale (2) = colorScale(2) + 0.1;
        ax(1) = subplot(1, 2, 1);
        imagesc([min(fraFree_freq), max(fraFree_freq)], ...
            [min(fraFree_atten), max(fraFree_atten)], ...
            fraFree)
        title(ax(1), [neuron(i).name, ' FRA free'])
        ylabel(ax(1), 'dB SPL')
        xlabel(ax(1), 'Frequency (kHz)')
        set(ax(1), 'TickLength',[0 0])
        set(ax(1), 'YTick', fliplr(fraFree_atten'))
        set(ax(1), 'YTickLabel', num2str(fraFree_atten))
        set(ax(1), 'CLim', colorScale)
        c = colorbar;
        c.Ticks = colorScale;
        c.Location = 'eastOutside';
        
    end
    if exist('fraHeld', 'var') == 1
        if any(isnan(fraHeld))
            disp('nans idiot')
            return
        end
        colorScale = quantile(reshape(fraHeld, 1, numel(fraHeld)), clims);
        colorScale (2) = colorScale(2) + 0.1;
        ax(2) = subplot(1, 2, 2);
        imagesc([min(fraHeld_freq), max(fraHeld_freq)], ...
            [min(fraHeld_atten), max(fraHeld_atten)], ...
            fraHeld)
        title(ax(2), [neuron(i).name, ' FRA held'])
        ylabel(ax(2), 'dB SPL')
        xlabel(ax(2), 'Frequency (kHz)')
        set(ax(2), 'TickLength',[0 0])
        set(ax(2), 'YTick', fliplr(fraHeld_atten'))
        set(ax(2), 'YTickLabel', num2str(fraHeld_atten))
        set(ax(2), 'CLim', colorScale)
        c = colorbar;
        c.Ticks = colorScale;
        c.Location = 'eastOutside';
        
    end
    clear ax fra*
    %     print('-dtiff','-r500',['C:\BLA paper\FRA images\', neuron(i).name, ' FRA.tif'])
    
end
