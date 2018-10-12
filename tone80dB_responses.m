% This script batches through FRA data saved in the structure 'neuron'.
% It automatically finds the frequencies and attenuations used.
% After calculating the FRA in free and held conditions, it is plotted and
% saved as a tiff file.
%
% Created by EHazlett 01/01/2018
%

window1 = [101, 300]; % window to calc response prestim = 100 poststim= 900
% cd('C:\BLA paper\FRA images\')
for i = 1:length(neuron)
    
    %% FRA Free
    if isfield(neuron(i).PSTH_1msbins, 'FRA_held') % is there a free_FRA
        fraHeld_freq = replace(fieldnames(neuron(i).PSTH_1msbins.FRA_held), 'Hz_', '');
        fraHeld_freq = cellfun(@str2num, fraHeld_freq); % find freq used in fra
             
        % Calculate mean response for each freq/ atten pair
        psther = [];
        for f = 1:length(fraHeld_freq)
            psth = neuron(i).PSTH_1msbins.FRA_held.(['Hz_', num2str(fraHeld_freq(f))]).dB_50;
            [~, col] = find(isnan(psth));
            psth(:, unique(col)) = []; % drop reps with NaN
            psther = [psther, psth];
            clear psth
        end
%         neuron(i).PSTH_1msbins.Tones_Held.Allfreqs.dB_50 = psther;
        clear psth*
    end
end
