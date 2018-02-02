% This script batches through FRA data saved in the structure 'neuron'.
% It automatically finds the frequencies and attenuations used.
% After calculating the FRA in free and held conditions, it is plotted and
% saved as a tiff file.
%
% Created by EHazlett 01/01/2018
%

window1 = [101, 300]; % window to calc response prestim = 100 poststim= 900
binSize = 20;
cd('C:\BLA paper\FRA images\')
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
        figure('units','normalized','outerposition',[0 0 1 1])
        count = 1;
        for a = 1:length(fraFree_atten)
            for f = 1:length(fraFree_freq)
                psth = neuron(i).PSTH_1msbins.FRA_free.(['Hz_', num2str(fraFree_freq(f))]).(['dB_', num2str(fraFree_atten(a))]);
                [bins, reps] = size(psth);
%                 bin = 0;
%                 for p = binSize+1:binSize:bins-binSize
%                     bin = bin + 1;
%                     psthBin (bin, 1:reps) = sum(psth(p-binSize:p+binSize, :));
%                 end
                
                subplot (4, 35, count)
                imagesc(psth(1:300,:)')
                set(gca,'xtick',[])
                set(gca,'ytick',[])
                set(gca, 'CLim', [0, 1])
                xlim([1 300])
                count = count + 1;
                clear psth*
            end
        end
        colormap([1 1 1; 0 0 0])
        title([neuron(i).name, ' - Free'])
        saveas(gca,[neuron(i).name, 'Free_rasters'], 'tiffn')
        close all
    else
    end
end
