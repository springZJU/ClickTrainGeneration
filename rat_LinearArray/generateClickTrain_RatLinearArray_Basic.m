
clearvars -except singleDuration s2CutOff ICIBase ratio Amp folderName repNs repN rIndex irregICISampNBase
mPath = mfilename("fullpath");
cd(fileparts(mPath));

%% important parameters
opts.fs = 97656;
% for continuous / seperated

s1ICI = repmat(ICIBase, 1, length(ratio)); % ms
s2ICI = reshape(ICIBase' * ratio, 1, []);

interval = 0; % ms
opts.rootPath = fullfile('..\..\ratLASounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
mkdir(opts.rootPath);

%% generate single click
opts.Amp = Amp;
opts.AmpS1 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s1ICI), "UniformOutput", false);
opts.AmpS2 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s2ICI), "UniformOutput", false);
opts.riseFallTime = 0; % ms
opts.clickDur = 0.2 ; % ms
click = generateClick(opts);

%% for click train long term
opts.repN = repN; % 
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
opts.fileNameTemp = [num2str(fix(singleDuration/1000)), 's_[s2ICI]_RegStdDev.wav'];

opts.fileNameRep = '[s2ICI]';
disp("exporting regular click train sounds...");
exportSoundFile({longTermRegWaveContinuous.s1s2}, opts)


% save continuous regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';

opts.fileNameTemp = [num2str(fix(singleDuration/1000)), 's_[s2ICI]_RegDevStd.wav'];
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermRegWaveContinuous.s2s1}, opts)




%%  irregular
% generate irregular click train
opts.baseICI =  4; % ms
opts.sigmaPara = 2; % sigma = ?? / sigmaPara
if ~exist("irregICISampNBase", "var")
    irregICISampNBase = cell2mat(irregICISampN(opts));
end
opts.irregICISampNBase = irregICISampNBase;
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


longTermIrregWaveStdDevContinuous = mergeSingleWave(s1IrregWaveTailRep, s2IrregWaveHeadRep, 0, opts, 0, s2CutOff);
longTermIrregWaveDevStdContinuous = mergeSingleWave(s2IrregWaveTailRep, s1IrregWaveHeadRep, 0, opts, 0, s2CutOff);

% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = [num2str(fix(singleDuration/1000)), 's_[s2ICI]_IrregStdDev_Rep', num2str(repN), '.wav'];
opts.fileNameRep = '[s2ICI]';
disp("exporting irregular click train sounds...");
exportSoundFile({longTermIrregWaveStdDevContinuous.s1s2}, opts)


% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';

opts.fileNameTemp = [num2str(fix(singleDuration/1000)), 's_[s2ICI]_IrregDevStd_Rep', num2str(repN), '.wav'];
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

save(fullfile(opts.rootPath, ['opts_Rep',  num2str(repN), '.mat']), 'opts');

