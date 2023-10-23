clear; clc

%% important parameters
opts.fs = 97656;
% for continuous / seperated
singleDuration = 3000;
s2CutOff = 1000;
ICIBase = [2 4 6 8 12];
ratio = [1, 1.1, 1.3, 1.5, 1.7];
s1ICI = repmat(ICIBase, 1, length(ratio)); % ms
s2ICI = [];
for s=1:length(ratio)
    s2ICI = [s2ICI,ICIBase * ratio(s)];
end
% s2ICI = [ICIBase .* ratio(1),ICIBase * ratio(2)];
% s2ICI = ICIBase * ratio;
interval = 0; % ms
% opts.rootPath = fullfile("..\ratSounds", strcat(datestr(now, "yyyy-mm-dd"), "_4-4.06"));
% opts.rootPath = fullfile("..\ratSounds", strcat("2022-10-11-", num2str(singleDuration/1000), "s"));
% opts.rootPath = fullfile('..\..\ratSounds', datestr(now, "yyyy-mm-dd"));
opts.rootPath = fullfile('..\..\ratSounds', strcat(datestr(now, "yyyy-mm-dd"), "_Ratio"));
% opts.rootPath = fullfile('..\monkeySounds', datestr(now, "yyyy-mm-dd"));
mkdir(opts.rootPath);

%% generate single click
opts.Amp = 0.1;
opts.AmpS1 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s1ICI), "UniformOutput", false);
opts.AmpS2 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s2ICI), "UniformOutput", false);
opts.riseFallTime = 0; % ms
opts.clickDur = evalin("base", "clickDur") ; % ms
click = generateClick(opts);

%% for click train long term
opts.repN = 0; % 
opts.click = click;
opts.trainLength = 100; % ms, single train
opts.soundLength = singleDuration; % ms, sound length, composed of N single trains
opts.ICIs = reshape([s1ICI; s2ICI], [], 1 ); % ms

%% regular
% generate regular long term click train
[RegWave, ~, ~, regClickTrainSampN] = generateRegClickTrain(opts);
s1RegWave = RegWave(1 : 2 : end);
s2RegWave = RegWave(2 : 2 : end);

longTermRegWaveContinuous = mergeSingleWave(s1RegWave, s2RegWave, 0, opts, 1, s2CutOff);
for sIndex = 1 : length(s1RegWave)
    s1RegWave{sIndex} = opts.AmpS1{sIndex} / opts.Amp * s1RegWave{sIndex} ;
    s2RegWave{sIndex} = opts.AmpS2{sIndex} / opts.Amp * s2RegWave{sIndex} ;
end
% normalize S2 SPL to S1 SPL 
longTermRegWaveContinuousNorm = mergeSingleWave(s1RegWave, s2RegWave, 0, opts, 1, s2CutOff);

% save continuous regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = [num2str(singleDuration/1000), 's_[s2ICI]_RegStdDev.wav'];
opts.fileNameRep = '[s2ICI]';
disp("exporting regular click train sounds...");
exportSoundFile({longTermRegWaveContinuous.s1s2}, opts)
opts.folderName = 'interval 0 Norm Sqrt';
exportSoundFile({longTermRegWaveContinuousNorm.s1s2}, opts)

% save continuous regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = [num2str(singleDuration/1000), 's_[s2ICI]_RegDevStd.wav'];
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermRegWaveContinuous.s2s1}, opts)
opts.folderName = 'interval 0 Norm Sqrt';
exportSoundFile({longTermRegWaveContinuousNorm.s2s1}, opts)






%% wave length for alignment
regStdDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s1RegWave, "UniformOutput", false);
regDevDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s2RegWave, "UniformOutput", false);


stimStr = cellfun(@(x) strjoin(x, "o"), array2VectorCell(string([s1ICI', s2ICI'])), "UniformOutput", false);
soundRealDuration = easyStruct(["stimStr", "regStdDuration", "regDevDuration"], ...
    [stimStr, regStdDuration, regDevDuration]);
opts.soundRealDuration = soundRealDuration;
opts.interval = interval;
opts.singleDuration = singleDuration;

save(fullfile(opts.rootPath, 'opts.mat'), 'opts');

