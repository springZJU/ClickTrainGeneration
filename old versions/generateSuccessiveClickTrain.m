clearvars -except singleDuration ; 
clc

%% important parameters
% basic
opts.fs = 97656;
% opts.rootPath = fullfile('..\ratSounds', datestr(now, "yyyy-mm-dd"));
% opts.rootPath = fullfile('..\monkeySounds', datestr(now, "yyyy-mm-dd"));
opts.rootPath = fullfile('..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_Oscillation"));

mkdir(opts.rootPath);

% for decode
decodeICI = [4 4.03 4.04 4.06 4.08  4.09 4.12 4.16 3 5 4.2 4.4 4.6 4.8];
decodeDuration = 300; % ms

% for continuous / seperated
s1ICI = [4, 4]; % ms
s2ICI = [4, 4.06];

% singleDuration = 200; % ms
successiveDuration = 10000; % ms
s2CutOff = []; % if empty, do not cut
interval = 500; % ms


%% generate single click
opts.Amp = 0.5;
opts.Amp1 = cellfun(@(x, y) normalizeClickTrainSPL(x, y, opts.Amp, 1), num2cell(s1ICI), num2cell(s2ICI), "UniformOutput", false);
opts.Amp2 = cellfun(@(x, y) normalizeClickTrainSPL(x, y, opts.Amp, 2), num2cell(s1ICI), num2cell(s2ICI), "UniformOutput", false);
opts.riseFallTime = 0; % ms
opts.clickDur = 0.2 ; % ms
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
opts.repN = 0; % 
opts.click = click;
opts.trainLength = 100; % ms, single train
opts.soundLength = singleDuration; % ms, sound length, composed of N single trains
opts.ICIs = reshape([s1ICI; s2ICI], [], 1 ); % ms
opts.successiveDuration = successiveDuration;

%% regular
% generate regular long term click train
[RegWave, ~, ~, regClickTrainSampN] = generateRegClickTrain(opts);
s1RegWave = RegWave(1 : 2 : end);
s2RegWave = RegWave(2 : 2 : end);
opts.s1HeadRep = s1RegWave; opts.s2HeadRep = s2RegWave; opts.s1TailRep = s1RegWave; opts.s2TailRep = s2RegWave;
longTermRegWaveContinuous = mergeSuccessiveWave(s1RegWave, s2RegWave, 0, opts, s2CutOff);
longTermRegWaveSepatated = mergeSuccessiveWave(s1RegWave, s2RegWave, interval, opts, s2CutOff); % interval unit: ms

% normalize S2 SPL to S1 SPL 
longTermRegWaveContinuousNorm1 = mergeSuccessiveWave(s1RegWave, opts.Amp1' ./ opts.Amp * s2RegWave, 0, opts, s2CutOff);
longTermRegWaveSepatatedNorm1 = mergeSuccessiveWave(s1RegWave, opts.Amp1' ./ opts.Amp * s2RegWave, interval, opts, s2CutOff); % interval unit: ms
longTermRegWaveContinuousNorm2 = mergeSuccessiveWave(s1RegWave, opts.Amp2' ./ opts.Amp * s2RegWave, 0, opts, s2CutOff);
longTermRegWaveSepatatedNorm2 = mergeSuccessiveWave(s1RegWave, opts.Amp2' ./ opts.Amp * s2RegWave, interval, opts, s2CutOff); % interval unit: ms




% save continuous regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'successive interval 0';
opts.fileNameTemp = ['[s2ICI]_RegStdDev_', num2str(singleDuration), '.wav'];
opts.fileNameRep = '[s2ICI]';
disp("exporting regular click train sounds...");
exportSoundFile({longTermRegWaveContinuous.s1s2}, opts)
opts.folderName = 'successive interval 0 Norm';
exportSoundFile({longTermRegWaveContinuousNorm1.s1s2}, opts)
opts.folderName = 'successive interval 0 Norm Sqrt';
exportSoundFile({longTermRegWaveContinuousNorm2.s1s2}, opts)


% save seperated regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'successive interval 600';
opts.fileNameTemp = ['[s2ICI]_RegStdDev_', num2str(singleDuration), '.wav'];
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermRegWaveSepatated.s1s2}, opts)
opts.folderName = 'successive interval 600 Norm';
exportSoundFile({longTermRegWaveSepatatedNorm1.s1s2}, opts)
opts.folderName = 'successive interval 600 Norm Sqrt';
exportSoundFile({longTermRegWaveSepatatedNorm2.s1s2}, opts)


%%  frozen irregular
% generate irregular click train
opts.singleDuration = singleDuration;
opts.baseICI =  4; % ms
opts.sigmaPara = 2; % sigma = μ / sigmaPara
load("standardIrregBase.mat");
load("first100ms_Base_30.mat");
standardIrregBase = [first100ms_IrregBase, standardIrregBase];
idx = find(cumsum(standardIrregBase) < ceil(opts.soundLength * opts.fs / 1000));
% opts.irregICISampNBase = cell2mat(irregICISampN(opts));
opts.irregICISampNBase = standardIrregBase(idx);
opts.irregLongTermSampN = opts.irregICISampNBase;
[~, ~, ~, irregSampN] = generateIrregClickTrain_Successive(opts);

s1IrregSampN = irregSampN(1 : 2 : end);
s1IrregRepN = regClickTrainSampN(2 : 2 : end);
s2IrregSampN = irregSampN(2 : 2 : end);
s2IrregRepN = regClickTrainSampN(1 : 2 : end);


opts.pos = 'head';
[opts.s1HeadRep, ~, s1IrregSampNHeadRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
[opts.s2HeadRep, ~, s2IrregSampNHeadRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);

opts.pos = 'tail';
[opts.s1TailRep, ~, s1IrregSampNTailRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
[opts.s2TailRep, ~, s2IrregSampNTailRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);

[s1IrregWave, ~, s1IrregSampN] = repIrregByReg(s1IrregSampNHeadRep, s1IrregRepN, opts);
[s2IrregWave, ~, s2IrregSampN] = repIrregByReg(s2IrregSampNHeadRep, s2IrregRepN, opts);

longTermIrregWaveStdDevContinuous = mergeSuccessiveWave(s1IrregWave, s2IrregWave, 0, opts, s2CutOff);
longTermIrregWaveStdDevSeperated = mergeSuccessiveWave(s1IrregWave, s2IrregWave, interval, opts, s2CutOff);

% normalize S2 SPL to S1 SPL 
longTermIrregWaveStdDevContinuousNorm1 = mergeSuccessiveWave(s1IrregWave, opts.Amp1' ./ opts.Amp * s2IrregWave, 0, opts, s2CutOff);
longTermIrregWaveStdDevSeperatedNorm1 = mergeSuccessiveWave(s1IrregWave, opts.Amp1' ./ opts.Amp * s2IrregWave, interval, opts, s2CutOff);

longTermIrregWaveStdDevContinuousNorm2 = mergeSuccessiveWave(s1IrregWave, opts.Amp2' ./ opts.Amp * s2IrregWave, 0, opts, s2CutOff);
longTermIrregWaveStdDevSeperatedNorm2 = mergeSuccessiveWave(s1IrregWave, opts.Amp2' ./ opts.Amp * s2IrregWave, interval, opts, s2CutOff);

% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'successive interval 0';
opts.fileNameTemp = ['[s2ICI]_IrregStdDev_frozen_', num2str(singleDuration), '.wav'];
opts.fileNameRep = '[s2ICI]';
disp("exporting irregular click train sounds...");
exportSoundFile({longTermIrregWaveStdDevContinuous.s1s2}, opts)
opts.folderName = 'successive interval 0 Norm';
exportSoundFile({longTermIrregWaveStdDevContinuousNorm1.s1s2}, opts)
opts.folderName = 'successive interval 0 Norm Sqrt';
exportSoundFile({longTermIrregWaveStdDevContinuousNorm2.s1s2}, opts)

% save seperated irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'successive interval 600';
opts.fileNameTemp = ['[s2ICI]_IrregStdDev_frozen_', num2str(singleDuration), '.wav'];
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermIrregWaveStdDevSeperated.s1s2}, opts)
save(fullfile(opts.rootPath, 'opts'), 'opts');
opts.folderName = 'successive interval 600 Norm';
exportSoundFile({longTermIrregWaveStdDevSeperatedNorm1.s1s2}, opts)
opts.folderName = 'successive interval 600 Norm Sqrt';
exportSoundFile({longTermIrregWaveStdDevSeperatedNorm2.s1s2}, opts)

%%  rand irregular
% generate irregular click train
if singleDuration < 100
    singleDuration = 100;
end
opts.soundLength = singleDuration; % 
segN = ceil(successiveDuration / singleDuration);
randIregTemp = cell(2, segN);
opts.baseICI =  4; % ms
opts.sigmaPara = 2; % sigma = μ / sigmaPara
intWave = zeros(ceil(interval / 1000 * opts.fs), 1);


for sIndex = 1 : segN
opts.irregICISampNBase = cell2mat(irregICISampN(opts));
opts.irregLongTermSampN = opts.irregICISampNBase;
[~, ~, ~, irregSampN] = generateIrregClickTrain_Successive(opts);

s1IrregSampN = irregSampN(1 : 2 : end, 1);
s2IrregSampN = irregSampN(2 : 2 : end, 1);

if sIndex == 1 % first segment
    opts.pos = 'tail';
    [irregWave(:, sIndex), ~, s1IrregSampNTailRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
    irregWaveNorm1(:, sIndex) = irregWave(:, sIndex);
    irregWaveNorm2(:, sIndex) = irregWave(:, sIndex);

elseif mod(sIndex, 1) == 0 % s2 segment
    opts.pos = 'head';
    [~, ~, s2IrregSampNHeadRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);
    opts.pos = 'tail';
    [irregWave(:, sIndex), ~, ~] = repIrregByReg(s2IrregSampNHeadRep, s2IrregRepN, opts);
    irregWaveNorm1(:, sIndex) = opts.Amp1' ./ opts.Amp * irregWave(:, sIndex);
    irregWaveNorm2(:, sIndex) = opts.Amp2' ./ opts.Amp * irregWave(:, sIndex);
elseif mod(sIndex, 1) == 1 % s1 segment
    opts.pos = 'head';
    [~, ~, s1IrregSampNHeadRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
    opts.pos = 'tail';
    [irregWave(:, sIndex), ~, ~] = repIrregByReg(s1IrregSampNHeadRep, s1IrregRepN, opts);
    irregWaveNorm1(:, sIndex) = opts.Amp1' ./ opts.Amp * irregWave(:, sIndex);
    irregWaveNorm2(:, sIndex) = opts.Amp2' ./ opts.Amp * irregWave(:, sIndex);
end

end

randIrreg = cellfun(@(x) cell2mat(x), array2VectorCell(cellfun(@(x) x', irregWave, "UniformOutput", false)), "UniformOutput", false);

% normalize S2 SPL to S1 SPL 
randIrregNorm1 = cellfun(@(x) cell2mat(x), array2VectorCell(cellfun(@(x) x', irregWaveNorm1, "UniformOutput", false)), "UniformOutput", false);
randIrregNorm2 = cellfun(@(x) cell2mat(x), array2VectorCell(cellfun(@(x) x', irregWaveNorm2, "UniformOutput", false)), "UniformOutput", false);




% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'successive interval 0';
opts.fileNameTemp = ['[s2ICI]_IrregStdDev_rand_', num2str(singleDuration), '.wav'];
opts.fileNameRep = '[s2ICI]';
disp("exporting irregular click train sounds...");
exportSoundFile(randIrreg, opts)
opts.folderName = 'interval 0 Norm';
exportSoundFile(randIrregNorm1, opts)
opts.folderName = 'interval 0 Norm Sqrt';
exportSoundFile(randIrregNorm2, opts)


%% wave length for alignment
regStdDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s1RegWave, "UniformOutput", false);
regDevDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s2RegWave, "UniformOutput", false);
irregStdDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s1IrregWave, "UniformOutput", false);
irregDevDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s2IrregWave, "UniformOutput", false);

stimStr = cellfun(@(x) strjoin(x, "o"), array2VectorCell(string([s1ICI', s2ICI'])), "UniformOutput", false);
soundRealDuration = easyStruct(["stimStr", "regStdDuration", "regDevDuration", "irregStdDuration", "irregDevDuration"], ...
    [stimStr, regStdDuration, regDevDuration, irregStdDuration, irregDevDuration]);
opts.soundRealDuration = soundRealDuration;
opts.interval = interval;
opts.decodeDuration = decodeDuration;
opts.decodeICI = decodeICI;
opts.singleDuration = singleDuration;

save(fullfile(opts.rootPath, 'opts'), 'opts');

