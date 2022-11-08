clear;
mPath = mfilename("fullpath");
cd(fileparts(mPath));

%% important parameters
opts.fs = 97656;
opts.rootPath = fullfile('..\..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_Offset2"));
mkdir(opts.rootPath);

% for decode

decodeICI = [15, 30, 60, 120];
decodeDuration = 3000; % ms


%% generate single click
opts.repN = 1; % 
opts.Amp = 1;
opts.clickDur = 0.2 ; % ms
opts.riseFallTime = 0; % ms
click = generateClick(opts);

%% for single click train
opts.click = click;
opts.trainLength = 100; % ms, single train
opts.soundLength = decodeDuration; % ms, sound length, composed of N single trains
opts.ICIs = decodeICI; % ms

% generate regular click train
[singleRegWave, regDur, ~, regClickTrainSampN] = generateRegClickTrain(opts);
for sIndex = 1 : length(singleRegWave)
    singleRegWave{sIndex} = [singleRegWave{sIndex}; click'];
end

% save regular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'decoding';
opts.fileNameTemp = [num2str(fix(decodeDuration/1000)), 's_[ICI]_Reg.wav'];
opts.fileNameRep = '[ICI]';
exportSoundFile(singleRegWave, opts)

%% irregular
% generate irregular click train
opts.baseICI =  4; % ms
opts.sigmaPara = 2; % sigma = μ / sigmaPara
opts.irregICISampNBase = cell2mat(irregICISampN(opts));
[~, ~, ~, irregSampN] = generateIrregClickTrain(opts);

s1IrregSampN = irregSampN;
s1IrregRepN = regClickTrainSampN;

opts.pos = 'tail';
[s1IrregWaveTailRep, ~, s1IrregSampNTailRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);

singleIrregWave = s1IrregWaveTailRep;
for sIndex = 1 : length(singleIrregWave)
    singleIrregWave{sIndex} = [singleIrregWave{sIndex}; click' ];
end

% save irregular single click train
opts.folderName = 'decoding';
opts.fileNameTemp = [num2str(fix(decodeDuration/1000)), 's_[ICI]_Irreg.wav'];
opts.fileNameRep = '[ICI]';
disp("exporting decoding sounds...");
exportSoundFile(singleIrregWave, opts)


%% wave length for alignment
regDuration = cellfun(@(x) length(x) * 1000 / opts.fs, singleRegWave, "UniformOutput", false);
irregDuration = cellfun(@(x) length(x) * 1000 / opts.fs, singleIrregWave, "UniformOutput", false);
stimStr = cellfun(@(x) x, string(decodeICI)', "uni", false);
soundRealDuration = easyStruct(["stimStr", "regDuration", "irregDuration"], ...
    [stimStr, regDuration, irregDuration]);
opts.soundRealDuration = soundRealDuration;
opts.singleDuration = decodeDuration;
save(fullfile(opts.rootPath, 'opts.mat'), 'opts');



