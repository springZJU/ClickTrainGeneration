clearvars -except decodeICI decodeDuration repDuration decodeICIs dIndex irregICISampNBase;
mPath = mfilename("fullpath");
cd(fileparts(mPath));
regRepN = fix(repDuration ./ decodeICI);

%% important parameters
opts.fs = 97656;
opts.rootPath = fullfile('..\..\RatSounds', strcat(datestr(now, "yyyy-mm-dd"), "_Offset_Rep_By_Duration"));
mkdir(opts.rootPath);

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
if ~exist("irregICISampNBase", "var")
    irregICISampNBase = cell2mat(irregICISampN(opts));
end
opts.irregICISampNBase = irregICISampNBase;
[~, ~, ~, irregSampN] = generateIrregClickTrain(opts);

s1IrregSampN = irregSampN;


%% export reg sound
opts.repN = regRepN; % 
s1RegRepN = s1IrregSampN;
opts.pos = 'tail';
[singleRegWave, ~, s1RegSampNTailRep] = repIrregByReg(regClickTrainSampN, s1RegRepN, opts);

for sIndex = 1 : length(singleRegWave)
    singleRegWave{sIndex} = [singleRegWave{sIndex}; click'];
end
% save regular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'offset';
opts.fileNameTemp = [num2str(fix((decodeDuration - repDuration)/1000)), 's_', num2str(fix((repDuration)/1000)), 's_[ICI]_Reg_Rep.wav'];
opts.fileNameRep = '[ICI]';
disp("exporting decoding sounds...");
exportSoundFile(singleRegWave, opts)

singleIrregWave = cellfun(@(x) flip(x), singleRegWave, "uni", false);
% save irregular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'offset';
opts.fileNameTemp = [num2str(fix((decodeDuration - repDuration)/1000)), 's_', num2str(fix((repDuration)/1000)), 's_[ICI]_Irreg_Rep.wav'];
opts.fileNameRep = '[ICI]';
exportSoundFile(singleIrregWave, opts)


