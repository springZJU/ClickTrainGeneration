% decodeDuration = 4000; % ms
% decodeICI = 15;
clearvars -except decodeDuration decodeICI decodeDurations dIndex irregICISampNBase;
mPath = mfilename("fullpath");
cd(fileparts(mPath));
irregRepN = 0;
regRepN = 0;

%% important parameters
opts.fs = 97656;
opts.rootPath = fullfile('..\..\RatSounds', strcat(datestr(now, "yyyy-mm-dd"), "_Offset_15_DiffDur"));
mkdir(opts.rootPath);

% for decode




%% generate single click

opts.Amp = 1;
opts.clickDur = evalin("base", "clickDur") ; % ms
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
if ~exist("irregICISampNBase", "var")
    irregICISampNBase = cell2mat(irregICISampN(opts));
end
opts.irregICISampNBase = irregICISampNBase;
[~, ~, ~, irregSampN] = generateIrregClickTrain(opts);

s1IrregSampN = irregSampN;
s1IrregRepN = regClickTrainSampN;


opts.repN = irregRepN; % 
opts.pos = 'tail';
[s1IrregWaveTailRep, ~, s1IrregSampNTailRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);

singleIrregWave = s1IrregWaveTailRep;
for sIndex = 1 : length(singleIrregWave)
    singleIrregWave{sIndex} = [singleIrregWave{sIndex}; click' ];
end

singleIrregWaveRev = cellfun(@(x) flip(x), singleIrregWave, "UniformOutput", false);

% save irregular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'offset';
opts.fileNameTemp = [num2str(fix(decodeDuration)), 'ms_[ICI]_Irreg', num2str(irregRepN), '.wav'];
opts.fileNameRep = '[ICI]';
disp("exporting decoding sounds...");
exportSoundFile(singleIrregWave, opts)
opts.fileNameTemp = [num2str(fix(decodeDuration)), 'ms_[ICI]_Irreg_Rev', num2str(irregRepN), '.wav'];
exportSoundFile(singleIrregWaveRev, opts)


%% export reg sound

opts.repN = regRepN; % 
s1RegRepN = s1IrregSampN;
opts.pos = 'tail';
[singleRegWave, ~, s1RegSampNTailRep] = repIrregByReg(regClickTrainSampN, s1RegRepN, opts);

for sIndex = 1 : length(singleRegWave)
    singleRegWave{sIndex} = [singleRegWave{sIndex}; click'];
end

singleRegWaveRev = cellfun(@(x) flip(x), singleRegWave, "UniformOutput", false);

% save regular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'offset';
opts.fileNameTemp = [num2str(fix(decodeDuration)), 'ms_[ICI]_Reg', num2str(regRepN), '.wav'];
opts.fileNameRep = '[ICI]';
exportSoundFile(singleRegWave, opts);
opts.fileNameTemp = [num2str(fix(decodeDuration)), 'ms_[ICI]_Reg_Rev', num2str(regRepN), '.wav'];
exportSoundFile(singleRegWaveRev, opts);



%% wave length for alignment


regDuration = cell2mat(cellfun(@(x) length(x) * 1000 / opts.fs, singleRegWave, "UniformOutput", false));
irregDuration = cell2mat(cellfun(@(x) length(x) * 1000 / opts.fs, singleIrregWave, "UniformOutput", false));
stimStr = cellfun(@(x) x, string(decodeICI)', "uni", false);
opts.singleDuration = decodeDuration;
opts.s1RegSampNTailRep = s1RegSampNTailRep;
opts.s1IrregSampNTailRep = s1IrregSampNTailRep;

regRepStr = cellstr(string(regRepN))';
irregRepStr = cellstr(string(irregRepN))';
opts.soundRealDuration =  easyStruct(["stimStr", "regRepStr", "irregRepStr", "regDuration", "irregDuration"], ...
    [stimStr, regRepStr, irregRepStr, regDuration, irregDuration]);
save(fullfile(opts.rootPath, 'opts.mat'), 'opts');
