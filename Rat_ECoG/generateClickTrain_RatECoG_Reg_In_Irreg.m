clear; clc

%% important parameters
opts.fs = 97656;
% for continuous / seperated
singleDuration = 3000;
s2CutOff = 1000;
ICIBase = [2, 4];
ratio = [1, 1.5];
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
opts.rootPath = fullfile('..\..\ratSounds', strcat(datestr(now, "yyyy-mm-dd"), "_RegInIrreg"));
% opts.rootPath = fullfile('..\monkeySounds', datestr(now, "yyyy-mm-dd"));
mkdir(opts.rootPath);

%% generate single click
opts.Amp = 0.1;
opts.AmpS1 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s1ICI), "UniformOutput", false);
opts.AmpS2 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s2ICI), "UniformOutput", false);
opts.riseFallTime = 0; % ms
opts.clickDur = 0.2 ; % ms
click = generateClick(opts);

%% for click train long term

opts.click = click;
opts.trainLength = 100; % ms, single train
opts.soundLength = singleDuration; % ms, sound length, composed of N single trains
opts.ICIs = reshape([s1ICI; s2ICI], [], 1 ); % ms

%% regular
% generate regular long term click train
[RegWave, ~, ~, regClickTrainSampN] = generateRegClickTrain(opts);
s1RegWave = RegWave(1 : 2 : end);
s2RegWave = RegWave(2 : 2 : end);
s1RegWaveCopy = s1RegWave;
s2RegWaveCopy = s2RegWave;
longTermRegWaveContinuous = mergeSingleWave(s1RegWaveCopy, s2RegWaveCopy, 0, opts, 1, s2CutOff);


% save continuous regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = [num2str(singleDuration/1000), 's_[s2ICI]_RegStdDev.wav'];
opts.fileNameRep = '[s2ICI]';
disp("exporting regular click train sounds...");
exportSoundFile({longTermRegWaveContinuous.s1s2}, opts)


% save continuous regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = [num2str(singleDuration/1000), 's_[s2ICI]_RegDevStd.wav'];
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermRegWaveContinuous.s2s1}, opts)




%%  irregular
% generate irregular click train
opts.baseICI =  4; % ms
opts.sigmaPara = 2; % sigma = ?? / sigmaPara
opts.irregICISampNBase = cell2mat(irregICISampN(opts));
opts.irregLongTermSampN = opts.irregICISampNBase;
[~, ~, ~, irregSampN] = generateIrregClickTrain(opts);

s1IrregSampN = irregSampN(1 : 2 : end);
s1IrregRepN = regClickTrainSampN(2 : 2 : end);

s2IrregSampN = irregSampN(2 : 2 : end);
s2IrregRepN = regClickTrainSampN(1 : 2 : end);


% No reg in irreg
opts.repN = 0; % 

opts.pos = 'head';
[s1IrregWaveHeadRep0, ~, s1IrregSampNHeadRep0] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
[s2IrregWaveHeadRep0, ~, s2IrregSampNHeadRep0] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);

opts.pos = 'tail';
[s1IrregWaveTailRep0, ~, s1IrregSampNTailRep0] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
[s2IrregWaveTailRep0, ~, s2IrregSampNTailRep0] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);





longTermIrregWaveStdDevContinuous = mergeSingleWave(s1IrregWaveTailRep0, s2IrregWaveHeadRep0, 0, opts, 0);
longTermIrregWaveDevStdContinuous = mergeSingleWave(s2IrregWaveTailRep0, s1IrregWaveHeadRep0, 0, opts, 0, s2CutOff);

% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0 No reg';
opts.fileNameTemp = '[s2ICI]_IrregStdDev.wav';
opts.fileNameRep = '[s2ICI]';
disp("exporting irregular click train sounds...");
exportSoundFile({longTermIrregWaveStdDevContinuous.s1s2}, opts)


% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0 No reg';
opts.fileNameTemp = '[s2ICI]_IrregDevStd.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermIrregWaveDevStdContinuous.s1s2}, opts)




% 3 reg in irreg
opts.repN = 3; % 

opts.pos = 'head';
[s1IrregWaveHeadRep3, ~, s1IrregSampNHeadRep3] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
[s2IrregWaveHeadRep3, ~, s2IrregSampNHeadRep3] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);

opts.pos = 'tail';
[s1IrregWaveTailRep3, ~, s1IrregSampNTailRep3] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
[s2IrregWaveTailRep3, ~, s2IrregSampNTailRep3] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);




longTermIrregWaveStdDevContinuous = mergeSingleWave(s1IrregWaveTailRep3, s2IrregWaveHeadRep3, 0, opts, 0);
longTermIrregWaveDevStdContinuous = mergeSingleWave(s2IrregWaveTailRep3, s1IrregWaveHeadRep3, 0, opts, 0, s2CutOff);

% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0 3Reg';
opts.fileNameTemp = '[s2ICI]_IrregStdDev.wav';
opts.fileNameRep = '[s2ICI]';
disp("exporting irregular click train sounds...");
exportSoundFile({longTermIrregWaveStdDevContinuous.s1s2}, opts)


% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0 3Reg';
opts.fileNameTemp = '[s2ICI]_IrregDevStd.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermIrregWaveDevStdContinuous.s1s2}, opts)




%% wave length for alignment
regStdDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s1RegWave, "UniformOutput", false);
regDevDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s2RegWave, "UniformOutput", false);
irregStdDuration0 = cellfun(@(x) length(x) * 1000 / opts.fs, s1IrregWaveTailRep0, "UniformOutput", false);
irregDevDuration0 = cellfun(@(x) length(x) * 1000 / opts.fs, s2IrregWaveTailRep0, "UniformOutput", false);
irregStdDuration3 = cellfun(@(x) length(x) * 1000 / opts.fs, s1IrregWaveTailRep3, "UniformOutput", false);
irregDevDuration3 = cellfun(@(x) length(x) * 1000 / opts.fs, s2IrregWaveTailRep3, "UniformOutput", false);

stimStr = cellfun(@(x) strjoin(x, "o"), array2VectorCell(string([s1ICI', s2ICI'])), "UniformOutput", false);
soundRealDuration = easyStruct(["stimStr", "regStdDuration", "regDevDuration", "irregStdDuration0", "irregDevDuration0", "irregStdDuration3", "irregDevDuration3"], ...
    [stimStr, regStdDuration, regDevDuration, irregStdDuration0, irregDevDuration0, irregStdDuration3, irregDevDuration3]);
opts.soundRealDuration = soundRealDuration;
opts.interval = interval;
opts.singleDuration = singleDuration;

save(fullfile(opts.rootPath, 'opts.mat'), 'opts');

