clearvars -except singleDuration ; 
clc

%% important parameters
% basic
opts.fs = 97656;
% opts.rootPath = fullfile('..\ratSounds', datestr(now, "yyyy-mm-dd"));
% opts.rootPath = fullfile('..\monkeySounds', datestr(now, "yyyy-mm-dd"));
opts.rootPath = fullfile('..\..\ratSounds', strcat(datestr(now, "yyyy-mm-dd"), "_Oscillation"));

mkdir(opts.rootPath);

% for decode
decodeICI = [4 4.03];
decodeDuration = 300; % ms

% for continuous / seperated
s1ICI = [2   , 4,    6,    8]; % ms
s2ICI = s1ICI*1.5;

% singleDuration = 200; % ms
successiveDuration = 10000; % ms
s2CutOff = []; % if empty, do not cut
interval = 500; % ms


%% generate single click
opts.Amp = 0.1;
opts.AmpS1 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s1ICI), "UniformOutput", false);
opts.AmpS2 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s2ICI), "UniformOutput", false);
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

% normalize S2 SPL to S1 SPL 
for sIndex = 1 : length(s1RegWave)
    s1RegWave{sIndex} = opts.AmpS1{sIndex} / opts.Amp * s1RegWave{sIndex} ;
    s2RegWave{sIndex} = opts.AmpS2{sIndex} / opts.Amp * s2RegWave{sIndex} ;
end
longTermRegWaveContinuousNorm = mergeSuccessiveWave(s1RegWave, s2RegWave, 0, opts, s2CutOff);




% save continuous regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'successive interval 0';
opts.fileNameTemp = ['[s2ICI]_RegStdDev_', num2str(singleDuration), '.wav'];
opts.fileNameRep = '[s2ICI]';
disp("exporting regular click train sounds...");
exportSoundFile({longTermRegWaveContinuous.s1s2}, opts)

opts.folderName = 'successive interval 0 Norm Sqrt';
exportSoundFile({longTermRegWaveContinuousNorm.s1s2}, opts)




%% wave length for alignment
regStdDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s1RegWave, "UniformOutput", false);
regDevDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s2RegWave, "UniformOutput", false);


stimStr = cellfun(@(x) strjoin(x, "o"), array2VectorCell(string([s1ICI', s2ICI'])), "UniformOutput", false);
soundRealDuration = easyStruct(["stimStr", "regStdDuration", "regDevDuration"], ...
    [stimStr, regStdDuration, regDevDuration]);
opts.soundRealDuration = soundRealDuration;
opts.interval = interval;
opts.decodeDuration = decodeDuration;
opts.decodeICI = decodeICI;
opts.singleDuration = singleDuration;

save(fullfile(opts.rootPath, 'opts'), 'opts');

