clear; clc
mPath = mfilename("fullpath");
cd(fileparts(mPath));
%% important parameters
opts.fs = 97656;
% for continuous / seperated
singleDuration = 6000;
s2CutOff = 4000;
ICIBase = [400];
ratio = [7/4];
s1ICI = repmat(ICIBase, 1, length(ratio)); % ms
s2ICI = [];
for s=1:length(ratio)
    s2ICI = [s2ICI,ICIBase * ratio(s)];
end
% s2ICI = [ICIBase .* ratio(1),ICIBase * ratio(2)];
% s2ICI = ICIBase * ratio;
interval = 0; % ms

opts.rootPath = fullfile('..\..\ratLASounds', strcat(datestr(now, "yyyy-mm-dd"), "_Rhythm"));
% opts.rootPath = fullfile('..\ratLASounds', datestr(now, "yyyy-mm-dd"));
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



%%  irregular
% generate irregular click train
opts.baseICI =  4; % ms
opts.sigmaPara = 2; % sigma = μ / sigmaPara
opts.irregICISampNBase = cell2mat(irregICISampN(opts));
opts.irregLongTermSampN = opts.irregICISampNBase;
[~, ~, ~, irregSampN] = generateIrregClickTrain(opts);

s1IrregSampN = irregSampN(1 : 2 : end);
s1IrregRepN = regClickTrainSampN(1 : 2 : end);

s2IrregSampN = irregSampN(2 : 2 : end);
s2IrregRepN = regClickTrainSampN(2 : 2 : end);

opts.pos = 'head';
[s1IrregWaveHeadRep, ~, s1IrregSampNHeadRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
[s2IrregWaveHeadRep, ~, s2IrregSampNHeadRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);

opts.pos = 'tail';
[s1IrregWaveTailRep, ~, s1IrregSampNTailRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
[s2IrregWaveTailRep, ~, s2IrregSampNTailRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);


longTermIrregWaveStdDevContinuous = mergeSingleWave(s1IrregWaveTailRep, s2IrregWaveHeadRep, 0, opts, 0);
longTermIrregWaveStdDevSeperated = mergeSingleWave(s1IrregWaveTailRep, s2IrregWaveHeadRep, interval, opts, 0);

longTermIrregWaveDevStdContinuous = mergeSingleWave(s2IrregWaveTailRep, s1IrregWaveHeadRep, 0, opts, 0, s2CutOff);
longTermIrregWaveDevStdSeperated = mergeSingleWave(s2IrregWaveTailRep, s1IrregWaveHeadRep, interval, opts, 0, s2CutOff);

% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = '[s2ICI]_IrregStdDev.wav';
opts.fileNameRep = '[s2ICI]';
disp("exporting irregular click train sounds...");
exportSoundFile({longTermIrregWaveStdDevContinuous.s1s2}, opts)


% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = '[s2ICI]_IrregDevStd.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermIrregWaveDevStdContinuous.s1s2}, opts)



%% wave length for alignment
regStdDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s1RegWave, "UniformOutput", false);
regDevDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s2RegWave, "UniformOutput", false);
irregStdDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s1IrregWaveTailRep, "UniformOutput", false);
irregDevDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s2IrregWaveTailRep, "UniformOutput", false);
stimStr = cellfun(@(x) strjoin(x, "o"), array2VectorCell(string([s1ICI', s2ICI'])), "UniformOutput", false);
soundRealDuration = easyStruct(["stimStr", "regStdDuration", "regDevDuration", "irregStdDuration", "irregDevDuration"], ...
    [stimStr, regStdDuration, regDevDuration, irregStdDuration, irregDevDuration]);
opts.soundRealDuration = soundRealDuration;
opts.interval = interval;
opts.singleDuration = singleDuration;

save(fullfile(opts.rootPath, 'opts.mat'), 'opts');

