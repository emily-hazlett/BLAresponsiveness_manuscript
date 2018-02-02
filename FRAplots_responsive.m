% This script batches through FRA data saved in the structure 'neuron'.
% It automatically finds the frequencies and attenuations used.
% After calculating the FRA in free and held conditions, it is plotted and
% saved as a tiff file.
%
% Created by EHazlett 01/01/2018
%

window1 = [101, 300]; % window to calc response prestim = 100 poststim= 900

bigFra1 = zeros(4,35);
bigFra2 = bigFra1;
bigFra3 = bigFra2;

count1 = 0;
count2 = 0;
count3 = 0;

mymap = [0,0,1
    0,0,0.75
    0,0,0.5
    0,0,0.25
    0,0,0
    0.25,0,0
    0.5,0,0
    0.75,0,0
    1,0,0];

FRAfreq = replace(fieldnames(neuron(1).PSTH_1msbins.FRA_free), 'Hz_', '');
FRAfreq = cellfun(@str2num, FRAfreq); % find freq used in fra

FRAatten = replace( ...
    fieldnames(neuron(1).PSTH_1msbins.FRA_free.(['Hz_', num2str(FRAfreq(1))])), ...
    'dB_', ''); % Find attens used for lowest frequency in fra
FRAatten = cellfun(@str2num, FRAatten);

for i = 1:length(neuron)
    %% FRA Free tUSV
    if isfield(neuron(i).PSTH_1msbins, 'FRA_free') % is there a free_FRA
%         if isfield(neuron(i).PSTH_1msbins, 'FRA_free') == 0 % is there a free_FRA
%             continue
%         end
        if neuron(i).responsive.tUSV ~= 0
            continue
        end
        
        fra = neuron(i).PSTH.free;
        fra1 = (fra*(1000/(window1(2)-window1(1)+1)) - neuron(i).OverallBG.free) ...
            ./ (fra*(1000/(window1(2)-window1(1)+1)) + neuron(i).OverallBG.free + 0.001);
        count1 = count1 +1;
        bigFra1 = bigFra1 + fra1;
        clear fra*
    else
    end
end

for i = 1:length(neuron)
    %% FRA Free sound unresponsive
    if isfield(neuron(i).PSTH_1msbins, 'FRA_free') % is there a free_FRA
%         if isfield(neuron(i).PSTH_1msbins, 'FRA_free') == 0 % is there a free_FRA
%             continue
%         end
        if neuron(i).responsive.stpUSV ~= 0
            continue
        end
        
        fra = neuron(i).PSTH.free;
        fra2 = (fra*(1000/(window1(2)-window1(1)+1)) - neuron(i).OverallBG.free) ...
            ./ (fra*(1000/(window1(2)-window1(1)+1)) + neuron(i).OverallBG.free + 0.001);
        count2 = count2 +1;
        bigFra2 = bigFra2 + fra2;
        clear fra*
    else
    end
end

for i = 1:length(neuron)
    %% FRA Free calls
    if isfield(neuron(i).PSTH_1msbins, 'FRA_free') % is there a free_FRA
%         if isfield(neuron(i).PSTH_1msbins, 'FRA_free') == 0 % is there a free_FRA
%             continue
%         end
        if neuron(i).responsive.calls ~= 0
            continue
        end
        
        fra = neuron(i).PSTH.free;
        fra3 = (fra*(1000/(window1(2)-window1(1)+1)) - neuron(i).OverallBG.free) ...
            ./ (fra*(1000/(window1(2)-window1(1)+1)) + neuron(i).OverallBG.free + 0.001);
        count3 = count1 +1;
        bigFra3 = bigFra3 + fra3;
        clear fra*
    else
    end
end

%% Plot FRAs
figure;
set(gcf,'position', [0, 0, 1250, 375])
ax(1) = subplot(1, 3, 1);
imagesc([min(FRAfreq), max(FRAfreq)], ...
    [min(FRAatten), max(FRAatten)], ...
    bigFra1/count1)
title(ax(1), 'Overall FRA Free - tUSV Responsive')
ylabel(ax(1), 'dB SPL')
xlabel(ax(1), 'Frequency (kHz)')
set(ax(1), 'TickLength',[0 0])
set(ax(1), 'YTick', fliplr(FRAatten'))
set(ax(1), 'YTickLabel', num2str(FRAatten))
set(ax(1), 'CLim', [-1, 1])
c = colorbar;
c.Location = 'eastOutside';

ax(2) = subplot(1, 3, 2);
imagesc([min(FRAfreq), max(FRAfreq)], ...
    [min(FRAatten), max(FRAatten)], ...
    bigFra2/count2)
title(ax(2), 'Overall FRA Free - stpUSV Responsive')
ylabel(ax(2), 'dB SPL')
xlabel(ax(2), 'Frequency (kHz)')
set(ax(2), 'TickLength',[0 0])
set(ax(2), 'YTick', fliplr(FRAatten'))
set(ax(2), 'YTickLabel', num2str(FRAatten))
set(ax(2), 'CLim', [-1, 1])
c = colorbar;
c.Location = 'eastOutside';

ax(3) = subplot(1, 3, 3);
imagesc([min(FRAfreq), max(FRAfreq)], ...
    [min(FRAatten), max(FRAatten)], ...
    bigFra3/count3)
title(ax(3), 'Overall FRA Free - Calls Responsive')
ylabel(ax(3), 'dB SPL')
xlabel(ax(3), 'Frequency (kHz)')
set(ax(3), 'TickLength',[0 0])
set(ax(3), 'YTick', fliplr(FRAatten'))
set(ax(3), 'YTickLabel', num2str(FRAatten))
set(ax(3), 'CLim', [-1, 1])
c = colorbar;
c.Location = 'eastOutside';

colormap(mymap)

% print('-dtiff','-r500','C:\BLA paper\FRA images\Overall_freeONLY_CategoryResponsive.tif')
