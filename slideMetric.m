slide = 5;
binsize = 20;

%% Find all tests
testsAll = {'BBN62_free1';'BBN62_free2';'BBN62_held1';'BBN62_held2'; 'BBN30_free1';'BBN30_free2';'BBN30_held1';'BBN30_held2';};
count = length(testsAll)+1;

usvAll = {'HighAgg';'p100_1';'p100_10';'p100_11';'p100_2';'p100_3';'p100_4';'p100_5';'p100_6';'p100_7';'p100_8';'p100_9'};
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
    testsAll{count, 1} = [usvAll{i}, '_rep_free'];
    count = count + 1;
end



psth = sum(neuron(1).PSTH_1msbins.BBN30_held1.BBN_30ms.dB_80, 2)';
bg = 

bin = 0;
for p = floor(binsize/2):slide:samples-floor(binsize/2)
    bin = bin + 1;
    psthBinSlide (bin) = sum(psth(p-floor(binsize/2)+1:p+floor(binsize/2)));
end

psthBinSlideHzM = (mean(psthBinSlide, 2) / binSize) * 1000;