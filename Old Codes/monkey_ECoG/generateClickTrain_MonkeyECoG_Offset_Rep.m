clear;
mPath = mfilename("fullpath");
cd(fileparts(mPath));
irregRepN = [1, 5, 10, 20, 40];
regRepN = [0, 5, 10, 20, 40];

%% important parameters
opts.fs = 97656;
opts.rootPath = fullfile('..\..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_Offset_15"));
mkdir(opts.rootPath);

% for decode

% decodeICI = [15, 30, 60, 120];
decodeICI = [15, 30, 60];
decodeDuration = 4000; % ms


%% generate single click

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
[~, regDur, ~, regClickTrainSampN] = generateRegClickTrain(opts);


%% irregular
% generate irregular click train
opts.baseICI =  4; % ms
opts.sigmaPara = 2; % sigma = μ / sigmaPara
opts.irregICISampNBase = cell2mat(irregICISampN(opts));
[~, ~, ~, irregSampN] = generateIrregClickTrain(opts);

s1IrregSampN = irregSampN;
s1IrregRepN = regClickTrainSampN;

for dIndex = 1 : length(irregRepN)
opts.repN = irregRepN(dIndex); % 
opts.pos = 'tail';
[s1IrregWaveTailRep, ~, s1IrregSampNTailRep{dIndex}] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);

singleIrregWave{dIndex} = s1IrregWaveTailRep;
for sIndex = 1 : length(singleIrregWave{dIndex})
    singleIrregWave{dIndex}{sIndex} = [singleIrregWave{dIndex}{sIndex}; click' ];
end

% save irregular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'decoding';
opts.fileNameTemp = [num2str(fix(decodeDuration/1000)), 's_[ICI]_Irreg_Rep', num2str(irregRepN(dIndex)), '.wav'];
opts.fileNameRep = '[ICI]';
disp("exporting decoding sounds...");
exportSoundFile(singleIrregWave{dIndex}, opts)
end

%% export reg sound
for dIndex = 1 : length(regRepN)
opts.repN = regRepN(dIndex); % 
s1RegRepN = s1IrregSampN;
opts.pos = 'tail';
[singleRegWave{dIndex}, ~, s1RegSampNTailRep{dIndex}] = repIrregByReg(regClickTrainSampN, s1RegRepN, opts);

for sIndex = 1 : length(singleRegWave{dIndex})
    singleRegWave{dIndex}{sIndex} = [singleRegWave{dIndex}{sIndex}; click'];
end

% save regular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'offset';
opts.fileNameTemp = [num2str(fix(decodeDuration/1000)), 's_[ICI]_Reg_Rep', num2str(regRepN(dIndex)), '.wav'];
opts.fileNameRep = '[ICI]';
exportSoundFile(singleRegWave{dIndex}, opts)
end

%% wave length for alignment

for dIndex = 1 : length(regRepN)
regDuration{dIndex, 1} = cell2mat(cellfun(@(x) length(x) * 1000 / opts.fs, singleRegWave{dIndex}, "UniformOutput", false));
irregDuration{dIndex, 1} = cell2mat(cellfun(@(x) length(x) * 1000 / opts.fs, singleIrregWave{dIndex}, "UniformOutput", false));
stimStr{dIndex, 1} = cellfun(@(x) x, string(decodeICI)', "uni", false);
opts.singleDuration = decodeDuration;
opts.s1RegSampNTailRep = s1RegSampNTailRep;
opts.s1IrregSampNTailRep = s1IrregSampNTailRep;
end
regRepStr = cellstr(string(regRepN))';
irregRepStr = cellstr(string(irregRepN))';
opts.soundRealDuration =  easyStruct(["stimStr", "regRepStr", "irregRepStr", "regDuration", "irregDuration"], ...
    [stimStr, regRepStr, irregRepStr, regDuration, irregDuration]);
save(fullfile(opts.rootPath, 'opts.mat'), 'opts');
