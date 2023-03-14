clear;
singleDuration = [1000 2000 3000 4000 5000]; % ms
s2CutOff = [{[]}, {1000}, {1000}, {1000}, {1000}]; % if empty, do not cut
for dIndex = 1 : length(singleDuration)
clearvars -except singleDuration s2CutOff opts dIndex; clc
%% important parameters
opts(dIndex).fs = 97656;
% for continuous / seperated

% ICIBase = [2, 3]; 
% ratio = 1.3;
% s1ICI = [ICIBase, ICIBase]; % ms
% s2ICI = roundn([ICIBase / ratio, ICIBase * ratio], -2);
s1ICI = 4; % ms
s2ICI = 4.06;
interval = 0; % ms
% opts(dIndex).rootPath = fullfile("..\ratSounds", strcat(datestr(now, "yyyy-mm-dd"), "_4-4.06"));
% opts(dIndex).rootPath = fullfile("..\ratSounds", strcat("2022-10-11-", num2str(singleDuration/1000), "s"));
% opts(dIndex).rootPath = fullfile('..\ratSounds', datestr(now, "yyyy-mm-dd"));
opts(dIndex).rootPath = fullfile('..\monkeySounds', datestr(now, "yyyy-mm-dd"));
mkdir(opts(dIndex).rootPath);

%% generate single click
opts(dIndex).Amp = 0.5;
opts(dIndex).AmpS1 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts(dIndex).Amp, 2), num2cell(s1ICI), "UniformOutput", false);
opts(dIndex).AmpS2 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts(dIndex).Amp, 2), num2cell(s2ICI), "UniformOutput", false);
opts(dIndex).riseFallTime = 0; % ms
opts(dIndex).clickDur = 0.2 ; % ms
click = generateClick(opts(dIndex));

%% for click train long term
opts(dIndex).repN = 3; % 
opts(dIndex).click = click;
opts(dIndex).trainLength = 100; % ms, single train
opts(dIndex).soundLength = singleDuration(dIndex); % ms, sound length, composed of N single trains
opts(dIndex).ICIs = reshape([s1ICI; s2ICI], [], 1 ); % ms

%% regular
% generate regular long term click train
[RegWave, ~, ~, regClickTrainSampN] = generateRegClickTrain(opts(dIndex));
s1RegWave = RegWave(1 : 2 : end);
s2RegWave = RegWave(2 : 2 : end);
longTermRegWaveContinuous = mergeSingleWave(s1RegWave, s2RegWave, 0, opts(dIndex), 1, s2CutOff{dIndex});

% normalize S2 SPL to S1 SPL 

longTermRegWaveContinuousNorm = mergeSingleWave(opts(dIndex).AmpS1' ./ opts(dIndex).Amp * s1RegWave, opts(dIndex).AmpS2' ./ opts(dIndex).Amp * s2RegWave, 0, opts(dIndex), 1, s2CutOff{dIndex});

% save continuous regular long term click train
opts(dIndex).ICIName = [s1ICI' s2ICI']; 
opts(dIndex).folderName = 'interval 0';
opts(dIndex).fileNameTemp = [num2str(singleDuration(dIndex)/1000), 's_[s2ICI]_RegStdDev.wav'];
opts(dIndex).fileNameRep = '[s2ICI]';
disp("exporting regular click train sounds...");
exportSoundFile({longTermRegWaveContinuous.s1s2}, opts(dIndex))
opts(dIndex).folderName = 'interval 0 Norm Sqrt';
exportSoundFile({longTermRegWaveContinuousNorm.s1s2}, opts(dIndex))

% save continuous regular long term click train
opts(dIndex).ICIName = [s1ICI' s2ICI']; 
opts(dIndex).folderName = 'interval 0';
opts(dIndex).fileNameTemp = [num2str(singleDuration(dIndex)/1000), 's_[s2ICI]_RegDevStd.wav'];
opts(dIndex).fileNameRep = '[s2ICI]';
exportSoundFile({longTermRegWaveContinuous.s2s1}, opts(dIndex))
opts(dIndex).folderName = 'interval 0 Norm Sqrt';
exportSoundFile({longTermRegWaveContinuousNorm.s2s1}, opts(dIndex))






%% wave length for alignment
regStdDuration = cellfun(@(x) length(x) * 1000 / opts(dIndex).fs, s1RegWave, "UniformOutput", false);
regDevDuration = cellfun(@(x) length(x) * 1000 / opts(dIndex).fs, s2RegWave, "UniformOutput", false);


stimStr = cellfun(@(x) strjoin(x, "o"), array2VectorCell(string([s1ICI', s2ICI'])), "UniformOutput", false);
soundRealDuration = easyStruct(["stimStr", "regStdDuration", "regDevDuration"], ...
    [stimStr, regStdDuration, regDevDuration]);
opts(dIndex).soundRealDuration = soundRealDuration;
opts(dIndex).interval = interval;
opts(dIndex).singleDuration = singleDuration(dIndex);
end
save(fullfile(opts(dIndex).rootPath, 'opts.mat'), 'opts');

