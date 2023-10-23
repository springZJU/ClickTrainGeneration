clear ; clc
%% vesion log
%20221010: change sqrt norm, each single click train whose ICI does not
%          equal 4 ms will be normalized to the level of 4ms. In addition,
%          delete the other norm method.



%% important parameters
% basic
opts.fs = 97656;
% opts.rootPath = fullfile('..\ratSounds', datestr(now, "yyyy-mm-dd"));
% opts.rootPath = fullfile('..\monkeySounds', datestr(now, "yyyy-mm-dd"));
opts.rootPath = fullfile('..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_ICIBase"));
mkdir(opts.rootPath);

% for decode
decodeICI = [4, 4.06];
% decodeICI = [1 2 3 4 5 6 7 8];
% decodeICI = [4 4.5 3 3.5 5 4.06];
decodeDuration = 200; % ms

% for continuous / seperated
% s1ICI = [4,    8,    20,   40,   80,   4, 4, 4,   4,   4,   4,   4,   3,   2.3]  ; % ms
% s2ICI = [4.06, 8.12, 20.3, 40.6, 81.2, 3, 5, 3.2, 3.4, 3.6, 3.8, 5.4, 2.3, 1.76];
% singleDuration = 5000; % ms
% s1ICI = [4, 4,    4,    4,    4,    4,    4,    4,   4,    4,   4,   4,   4,   4, 2,   8,   14,   20, 30, 40, 80]  ; % ms
% s2ICI = [4, 4.01, 4.02, 4.03, 4.04, 4.05, 4.06, 4.1, 4.15, 4.2, 4.4, 4.6, 4.8, 5, 2.2, 8.8, 15.4, 22, 33, 44, 88];

s1ICI = [4,    8,   ]; % ms
s2ICI = [4.06, 8.12];
singleDuration = 5000; % ms
s2CutOff = 2000; % if empty, do not cut
interval = 500; % ms


%% generate single click
opts.Amp = 1;
opts.AmpS1 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s1ICI), "UniformOutput", false);
opts.AmpS2 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s2ICI), "UniformOutput", false);
opts.riseFallTime = 0; % ms
opts.clickDur = evalin("base", "clickDur") ; % ms
click = generateClick(opts);

%% for single click train
opts.click = click;
opts.trainLength = 100; % ms, single train
opts.soundLength = decodeDuration; % ms, sound length, composed of N single trains
opts.ICIs = decodeICI; % ms

% generate regular click train
[singleRegWave, regDur] = generateRegClickTrain(opts);

% save regular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'decoding';
opts.fileNameTemp = '[ICI]_Reg.wav';
opts.fileNameRep = '[ICI]';
exportSoundFile(singleRegWave, opts)

% generate irregular click train
opts.baseICI =  4; % ms
opts.sigmaPara = 2; % sigma = μ / sigmaPara
opts.irregICISampNBase = cell2mat(irregICISampN(opts));
opts.irregSingleSampN = opts.irregICISampNBase;
singleIrregWave = generateIrregClickTrain(opts);

% save irregular single click train
opts.folderName = 'decoding';
opts.fileNameTemp = '[ICI]_Irreg.wav';
opts.fileNameRep = '[ICI]';
disp("exporting decoding sounds...");
exportSoundFile(singleIrregWave, opts)

%% for click train long term
opts.repN = 3; % 
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
longTermRegWaveSepatated = mergeSingleWave(s1RegWave, s2RegWave, interval, opts, 1, s2CutOff); % interval unit: ms

% normalize S2 SPL to S1 SPL 
longTermRegWaveContinuousNorm = mergeSingleWave(opts.AmpS1' ./ opts.Amp * s1RegWave, opts.AmpS2' ./ opts.Amp * s2RegWave, 0, opts, 1, s2CutOff);
longTermRegWaveSepatatedNorm = mergeSingleWave(opts.AmpS1' ./ opts.Amp * s1RegWave, opts.AmpS2' ./ opts.Amp * s2RegWave, interval, opts, 1, s2CutOff); % interval unit: ms

% save continuous regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = '[s2ICI]_RegStdDev.wav';
opts.fileNameRep = '[s2ICI]';
disp("exporting regular click train sounds...");
exportSoundFile({longTermRegWaveContinuous.s1s2}, opts)
opts.folderName = 'interval 0 Norm Sqrt';
exportSoundFile({longTermRegWaveContinuousNorm.s1s2}, opts)

% save continuous regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = '[s2ICI]_RegDevStd.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermRegWaveContinuous.s2s1}, opts)
opts.folderName = 'interval 0 Norm Sqrt';
exportSoundFile({longTermRegWaveContinuousNorm.s2s1}, opts)

% save seperated regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 600';
opts.fileNameTemp = '[s2ICI]_RegStdDev.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermRegWaveSepatated.s1s2}, opts)
opts.folderName = 'interval 600 Norm Sqrt';
exportSoundFile({longTermRegWaveSepatatedNorm.s1s2}, opts)

% save seperated regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 600';
opts.fileNameTemp = '[s2ICI]_RegDevStd.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermRegWaveSepatated.s2s1}, opts)
opts.folderName = 'interval 600 Norm Sqrt';
exportSoundFile({longTermRegWaveSepatatedNorm.s2s1}, opts)


%%  irregular
% generate irregular click train
opts.baseICI =  4; % ms
opts.sigmaPara = 2; % sigma = μ / sigmaPara
opts.irregICISampNBase = cell2mat(irregICISampN(opts));
opts.irregLongTermSampN = opts.irregICISampNBase;
[~, ~, ~, irregSampN] = generateIrregClickTrain(opts);

s1IrregSampN = irregSampN(1 : 2 : end);
s1IrregRepN = regClickTrainSampN(2 : 2 : end);

s2IrregSampN = irregSampN(2 : 2 : end);
s2IrregRepN = regClickTrainSampN(1 : 2 : end);



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

% normalize S2 SPL to S1 SPL 
longTermIrregWaveStdDevContinuousNorm = mergeSingleWave(opts.AmpS1' ./ opts.Amp * s1IrregWaveTailRep, opts.AmpS2' ./ opts.Amp * s2IrregWaveHeadRep, 0, opts, 0, s2CutOff);
longTermIrregWaveStdDevSeperatedNorm = mergeSingleWave(opts.AmpS1' ./ opts.Amp * s1IrregWaveTailRep, opts.AmpS2' ./ opts.Amp * s2IrregWaveHeadRep, interval, opts, 0, s2CutOff);

longTermIrregWaveDevStdContinuousNorm = mergeSingleWave(opts.AmpS1' ./ opts.Amp * s2IrregWaveTailRep, opts.AmpS2' ./ opts.Amp * s1IrregWaveHeadRep, 0, opts, 0, s2CutOff);
longTermIrregWaveDevStdSeperatedNorm = mergeSingleWave(opts.AmpS1' ./ opts.Amp * s2IrregWaveTailRep, opts.AmpS2' ./ opts.Amp * s1IrregWaveHeadRep, interval, opts, 0, s2CutOff);


% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = '[s2ICI]_IrregStdDev.wav';
opts.fileNameRep = '[s2ICI]';
disp("exporting irregular click train sounds...");
exportSoundFile({longTermIrregWaveStdDevContinuous.s1s2}, opts)
opts.folderName = 'interval 0 Norm Sqrt';
exportSoundFile({longTermIrregWaveStdDevContinuousNorm.s1s2}, opts)

% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = '[s2ICI]_IrregDevStd.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermIrregWaveDevStdContinuous.s1s2}, opts)
opts.folderName = 'interval 0 Norm Sqrt';
exportSoundFile({longTermIrregWaveDevStdContinuousNorm.s1s2}, opts)

% save seperated irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 600';
opts.fileNameTemp = '[s2ICI]_IrregStdDev.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermIrregWaveStdDevSeperated.s1s2}, opts)
save(fullfile(opts.rootPath, 'opts'), 'opts');
opts.folderName = 'interval 600 Norm Sqrt';
exportSoundFile({longTermIrregWaveStdDevSeperatedNorm.s1s2}, opts)

% save seperated irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 600';
opts.fileNameTemp = '[s2ICI]_IrregDevStd.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermIrregWaveDevStdSeperated.s1s2}, opts)
opts.folderName = 'interval 600 Norm Sqrt';
exportSoundFile({longTermIrregWaveDevStdSeperatedNorm.s1s2}, opts)




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
opts.decodeDuration = decodeDuration;
opts.decodeICI = decodeICI;
opts.singleDuration = singleDuration;

save(fullfile(opts.rootPath, 'opts'), 'opts');

