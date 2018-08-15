count = 1;
for i = 1:length(neuron)
    if strcmp (neuron(i).name, neuronIndex{count})
        neuron(i).Responsive.USV = responsive(count);
        count = count+1;
    end
end




% %% import ISG data
%
% target = '62_free1';
% num = 100;
% file = importdata ('876_092713_halfturn_free_Char_BBN30_1_SpreadsheetUnit1.txt');
% stims = file.textdata(1,2:end);
% reps = file.data(2:end, :);
%
% target = ['ISG500_BBN', target];
% attenfield = 'dB_80';
%
% stimList = unique(stims);
%
% if isfield(neuron(num).PSTH_1msbins, target) == false
%     disp('not a field')
%     beep
%     return
% end
%
% for n = 1:length(stimList)
%     grouper = strcmp(stimList{n}, stims); % drop reps for this stim
%     stimX = stims(:,grouper);
%     repsX = reps(:, grouper);
%     neuron(num).PSTH_1msbins.(target).(stimList{n}).(attenfield) = repsX;
%     clear stimX* repsX* attensX* attenfield
% end
% clear grouper* atten* stim* rep* file n p target num



% %% Import FRA data
%
% target = 'FRA_held';
% num = 27;
% file = importdata ('881_120513_held_FRA_1_SpreadsheetUnit1.txt');
% stims = file.textdata(2,2:end);
% attens = file.data(1, :);
% reps = file.data(2:end, :);
%
% stimList = unique(stims);
% attenList = unique(attens);
%
% if isfield(neuron(num).PSTH_1msbins, target) == false
%     disp('not a field')
%     beep
%     return
% end
%
% for n = 1:length(stimList)
%     grouper = strcmp(stimList{n}, stims); % drop reps for this stim
%     stimX = stims(:,grouper);
%     repsX = reps(:, grouper);
%     attensX = attens(:, grouper);
%     for p = 1:length(attenList)
%         grouperX = find(attensX == attenList(p)); % drop reps for this atten
%         if isempty(stimX(grouperX)) %Don't do anything if all reps are dropped
%             continue
%         end
%         stimXX = stimX(:,grouperX);
%         repsXX = repsX(:, grouperX);
%         switch attenList(p)
%             case 0
%                 attenfield = 'dB_80';
%             case 10
%                 attenfield = 'dB_70';
%             case 20
%                 attenfield = 'dB_60';
%             case 30
%                 attenfield = 'dB_50';
%         end
%         stimfield = stimList{n};
%         stimfield = strrep(stimfield,'Hz','');
%         stimfield = ['Hz_', stimfield];
%
%         if isfield(neuron(num).PSTH_1msbins.(target), stimfield) == false
%             disp('not a field')
%             beep
%             return
%         end
%
%         neuron(num).PSTH_1msbins.(target).(stimfield).(attenfield) = repsXX;
%     end
%     clear stimX* repsX* attensX* *field
% end
% clear grouper* atten* stim* rep* file n p target num
%
%
% %% import BBN and USV data
%
% target = 'BBN30_free1';
% num = 1;
% file = importdata ('876_092713_halfturn_free_Char_BBN30_1_SpreadsheetUnit1.txt');
% stims = file.textdata(2,2:end);
% attens = file.data(1, :);
% reps = file.data(2:end, :);
%
% stimList = unique(stims);
% attenList = unique(attens);
%
% % if isfield(neuron(num).PSTH_1msbins, target) == false
% %     disp('not a field')
% %     beep
% %     return
% % end
%
% for n = 1:length(stimList)
%     grouper = strcmp(stimList{n}, stims); % drop reps for this stim
%     stimX = stims(:,grouper);
%     repsX = reps(:, grouper);
%     attensX = attens(:, grouper);
%     for p = 1:length(attenList)
%         grouperX = find(attensX == attenList(p)); % drop reps for this atten
%         if isempty(stimX(grouperX)) %Don't do anything if all reps are dropped
%             continue
%         end
%         stimXX = stimX(:,grouperX);
%         repsXX = repsX(:, grouperX);
%         switch contains(stimList{n}, 'BBN')
%             case 1
%                 switch attenList(p)
%                     case 0
%                         attenfield = 'dB_90';
%                     case 10
%                         attenfield = 'dB_80';
%                     case 20
%                         attenfield = 'dB_70';
%                     case 30
%                         attenfield = 'dB_60';
%                     case 40
%                         attenfield = 'dB_50';
%                 end
%             case 0
%                 switch attenList(p)
%                     case 0
%                         attenfield = 'dB_80';
%                     case 10
%                         attenfield = 'dB_70';
%                     case 20
%                         attenfield = 'dB_60';
%                     case 30
%                         attenfield = 'dB_50';
%                 end
%         end
%         neuron(num).PSTH_1msbins.(target).(stimList{n}).(attenfield) = repsXX;
%     end
%     clear stimX* repsX* attensX* attenfield
% end
% clear grouper* atten* stim* rep* file n p target num



% cheese = cell array of neuron name, date, and animalNum
% pie = logical array of tests

% %test fields
% for num = 1:115
%     neuron(num).name = cheese{num,1};
%     neuron(num).date = cheese{num, 2};
%     neuron(num).animalNum = cheese{num, 3};

%     neuron(num).testsLogical.BBN62_free1 = pie(1,num);
%     neuron(num).testsLogical.BBN62_free2 = pie(2, num);
%     neuron(num).testsLogical.BBN62_held1 = pie(3, num);
%     neuron(num).testsLogical.BBN62_held2 = pie(4, num);
%     neuron(num).testsLogical.BBN62_RLF_free1 = pie(5, num);
%     neuron(num).testsLogical.BBN62_RLF_free2 = pie(6, num);
%     neuron(num).testsLogical.BBN62_RLF_held = pie(7, num);
%     neuron(num).testsLogical.BBN30_free1 = pie(8, num);
%     neuron(num).testsLogical.BBN30_free2 = pie(9, num);
%     neuron(num).testsLogical.BBN30_held1 = pie(10, num);
%     neuron(num).testsLogical.BBN30_held2 = pie(11, num);
%     neuron(num).testsLogical.BBN30_RLF_free1 = pie(12, num);
%     neuron(num).testsLogical.BBN30_RLF_free2 = pie(13, num);
%     neuron(num).testsLogical.BBN30_RLF_held = pie(14, num);
%     neuron(num).testsLogical.USV_rand_free1 = pie(15, num);
%     neuron(num).testsLogical.USV_rand_free2 = pie(16, num);
%     neuron(num).testsLogical.USV_rand_held1 = pie(17, num);
%     neuron(num).testsLogical.USV_rep_free = pie(18, num);
%     neuron(num).testsLogical.FRA_free = pie(19, num);
%     neuron(num).testsLogical.FRA_held = pie(20, num);
%
%     neuron(num).testsLogical.ISG500_BBN30_free1 = pie(1, num);
%     neuron(num).testsLogical.ISG500_BBN30_free2 = pie(2, num);
%     neuron(num).testsLogical.ISG500_BBN30_held1 = pie(3, num);
%     neuron(num).testsLogical.ISG500_BBN30_held2 = pie(4, num);
%     neuron(num).testsLogical.ISG500_BBN62_free1 = pie(5, num);
%     neuron(num).testsLogical.ISG500_BBN62_free2 = pie(6, num);
%     neuron(num).testsLogical.ISG500_BBN62_held1 = pie(7, num);
%     neuron(num).testsLogical.ISG500_BBN62_held2 = pie(8, num);
% end
%
% %1ms bin PSTH fields
% for num = 1:115
%
%     if neuron(num).testsLogical.BBN62_free1 == 1
%         neuron(num).PSTH_1msbins.BBN62_free1 = [];
%     end
%
%     if neuron(num).testsLogical.BBN62_free2 == 1
%         neuron(num).PSTH_1msbins.BBN62_free2 = [];
%     end
%
%     if neuron(num).testsLogical.BBN62_held1 == 1
%         neuron(num).PSTH_1msbins.BBN62_held1 = [];
%     end
%
%     if neuron(num).testsLogical.BBN62_held2 == 1
%         neuron(num).PSTH_1msbins.BBN62_held2 = [];
%     end
%
%     if neuron(num).testsLogical.BBN62_RLF_free1 == 1
%         neuron(num).PSTH_1msbins.BBN62_RLF_free1 = [];
%     end
%
%     if neuron(num).testsLogical.BBN62_RLF_free2 == 1
%         neuron(num).PSTH_1msbins.BBN62_RLF_free2 = [];
%     end
%
%     if neuron(num).testsLogical.BBN62_RLF_held == 1
%         neuron(num).PSTH_1msbins.BBN62_RLF_held = [];
%     end
%
%     if neuron(num).testsLogical.BBN30_free1 == 1
%         neuron(num).PSTH_1msbins.BBN30_free1 = [];
%     end
%
%     if neuron(num).testsLogical.BBN30_free2 == 1
%         neuron(num).PSTH_1msbins.BBN30_free2 = [];
%     end
%
%     if neuron(num).testsLogical.BBN30_held1 == 1
%         neuron(num).PSTH_1msbins.BBN30_held1 = [];
%     end
%
%     if neuron(num).testsLogical.BBN30_held2 == 1
%         neuron(num).PSTH_1msbins.BBN30_held2 = [];
%     end
%
%     if neuron(num).testsLogical.BBN30_RLF_free1 == 1
%         neuron(num).PSTH_1msbins.BBN30_RLF_free1 = [];
%     end
%
%     if neuron(num).testsLogical.BBN30_RLF_free2 == 1
%         neuron(num).PSTH_1msbins.BBN30_RLF_free2 = [];
%     end
%
%     if neuron(num).testsLogical.BBN30_RLF_held == 1
%         neuron(num).PSTH_1msbins.BBN30_RLF_held = [];
%     end
%
%     if neuron(num).testsLogical.USV_rand_free1 == 1
%         neuron(num).PSTH_1msbins.USV_rand_free1 = [];
%     end
%
%     if neuron(num).testsLogical.USV_rand_free2 == 1
%         neuron(num).PSTH_1msbins.USV_rand_free2 = [];
%     end
%
%     if neuron(num).testsLogical.USV_rand_held1 == 1
%         neuron(num).PSTH_1msbins.USV_rand_held1 = [];
%     end
%
%     if neuron(num).testsLogical.USV_rep_free == 1
%         neuron(num).PSTH_1msbins.USV_rep_free = [];
%     end
%
%     if neuron(num).testsLogical.FRA_free == 1
%         neuron(num).PSTH_1msbins.FRA_free = [];
%     end
%
%     if neuron(num).testsLogical.FRA_held == 1
%         neuron(num).PSTH_1msbins.FRA_held = [];
%     end
%
%     if neuron(num).testsLogical.ISG500_BBN30_free1 == 1
%         neuron(num).PSTH_1msbins.ISG500_BBN30_free1 = [];
%     end
%     if neuron(num).testsLogical.ISG500_BBN30_free2 == 1
%         neuron(num).PSTH_1msbins.ISG500_BBN30_free2 = [];
%     end
%     if neuron(num).testsLogical.ISG500_BBN30_held1 == 1
%         neuron(num).PSTH_1msbins.ISG500_BBN30_held1 = [];
%     end
%     if neuron(num).testsLogical.ISG500_BBN30_held2 == 1
%         neuron(num).PSTH_1msbins.ISG500_BBN30_held2 = [];
%     end
%     if neuron(num).testsLogical.ISG500_BBN62_free1 == 1
%         neuron(num).PSTH_1msbins.ISG500_BBN62_free1 = [];
%     end
%     if neuron(num).testsLogical.ISG500_BBN62_free2 == 1
%         neuron(num).PSTH_1msbins.ISG500_BBN62_free2 = [];
%     end
%     if neuron(num).testsLogical.ISG500_BBN62_held1 == 1
%         neuron(num).PSTH_1msbins.ISG500_BBN62_held1 = [];
%     end
%     if neuron(num).testsLogical.ISG500_BBN62_held2 == 1
%         neuron(num).PSTH_1msbins.ISG500_BBN62_held2 = [];
%     end
% end
% % FRA fields
% for num = 101:115
%     if isfield(neuron(num).PSTH_1msbins,'FRA_free') == 1
%         neuron(num).PSTH_1msbins.FRA_free = struct( ...
%             'Hz_4000', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_4400', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_4840', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_5324', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_5856', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_6442', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_7086', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_7795', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_8574', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_9432', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_10375', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_11412', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_12554', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_13809', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_15190', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_16709', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_18380', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_20218', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_22240', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_24464', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_26910', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_29601', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_32561', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_35817', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_39399', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_43339', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_47673', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_52440', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_57684', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_63452', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_69798', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_76777', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_84455', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_92901', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]), ...
%             'Hz_102191', struct('dB_80', [], 'dB_70', [], 'dB_60', [], 'dB_50',[]) ...
%             );
%     end
% end


























