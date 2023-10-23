% decodeDuration = 4000; % ms
% decodeICI = 15;
clearvars -except decodeDuration decodeICI decodeDurations Amp dIndex irregICISampNBase folderName;
mPath = mfilename("fullpath");
cd(fileparts(mPath));

irregRepN = 1;
regRepN = 0;

%% important parameters
opts.fs = 97656;
opts.rootPath = fullfile('..\..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
mkdir(opts.rootPath);

%% generate single click
opts.Amp = Amp;
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
[~, ~, s1IrregSampNTailRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);

opts.repN = irregRepN; % 
opts.pos = 'head';
[s1IrregWaveHeadTailRep, ~, s1IrregSampNHeadTailRep] = repIrregByReg(s1IrregSampNTailRep, s1IrregRepN, opts);




singleIrregWave = s1IrregWaveHeadTailRep;
for sIndex = 1 : length(singleIrregWave)
    singleIrregWave{sIndex} = [singleIrregWave{sIndex}; click' ];
end

singleIrregWaveRev = cellfun(@(x) flip(x), singleIrregWave, "UniformOutput", false);

% save irregular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'offset';
opts.fileNameTemp = [num2str(fix(decodeDuration)), 'ms_[ICI]_Irreg_Rep', num2str(irregRepN), '.wav'];
opts.fileNameRep = '[ICI]';
disp("exporting decoding sounds...");
exportSoundFile(singleIrregWave, opts)
opts.fileNameTemp = [num2str(fix(decodeDuration)), 'ms_[ICI]_Irreg_Rev_Rep', num2str(irregRepN), '.wav'];
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
opts.fileNameTemp = [num2str(fix(decodeDuration)), 'ms_[ICI]_Reg_Rep', num2str(regRepN), '.wav'];
opts.fileNameRep = '[ICI]';
exportSoundFile(singleRegWave, opts);
opts.fileNameTemp = [num2str(fix(decodeDuration)), 'ms_[ICI]_Reg_Rev_Rep', num2str(regRepN), '.wav'];
exportSoundFile(singleRegWaveRev, opts);
