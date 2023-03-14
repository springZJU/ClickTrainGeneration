clearvars -except decodeICI decodeDuration repDuration decodeICIs dIndex irregICISampNBase singleCutOff folderName;
mPath = mfilename("fullpath");
cd(fileparts(mPath));
regRepN = fix(repDuration ./ decodeICI);


%% important parameters
opts.fs = 97656;
opts.rootPath = fullfile('..\..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
mkdir(opts.rootPath);

tLength = sum(singleCutOff) / 1000 * opts.fs;
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
[singleRegWaveCopy, ~, s1RegSampNTailRep] = repIrregByReg(regClickTrainSampN, s1RegRepN, opts);

for sIndex = 1 : length(singleRegWaveCopy)
    singleRegWaveCopy{sIndex} = [singleRegWaveCopy{sIndex}; click'];
end

% cut wave
if ~isempty(singleCutOff) && singleCutOff(1) < singleCutOff(2)
    singleRegWave = cellfun(@(x) x(end - tLength : end), singleRegWaveCopy, "UniformOutput", false);
elseif ~isempty(singleCutOff) && singleCutOff(1) >= singleCutOff(2)
    singleRegWave = cellfun(@(x) x(1 : tLength), singleRegWaveCopy, "UniformOutput", false);
else
    singleRegWave = singleRegWaveCopy;
end

for sIndex = 1 : length(singleRegWave)
    onIndex = find(singleRegWave{sIndex} > 0);
    singleRegWave{sIndex, 1}(1 : onIndex(1)-1) = [];
end

% save regular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'offset';
if isempty(singleCutOff)
    opts.fileNameTemp = [num2str(fix((decodeDuration - repDuration) / 1000)), 's_', num2str(fix(repDuration / 1000)), 's_[ICI]_Reg_Rep.wav'];
else
    opts.fileNameTemp = [num2str(fix(singleCutOff(1) / 1000)), 's_', num2str(fix(singleCutOff(2) / 1000)), 's_[ICI]_Reg_Rep.wav'];
end
opts.fileNameRep = '[ICI]';
disp("exporting decoding sounds...");
exportSoundFile(singleRegWave, opts)

%% export irreg wave
singleIrregWaveTemp = cellfun(@(x) flip(x), singleRegWaveCopy, "uni", false);
% cut wave
if ~isempty(singleCutOff) && singleCutOff(1) < singleCutOff(2)
    tLength = sum(singleCutOff) / 1000 * opts.fs;
    singleIrregWave = cellfun(@(x) x(end - tLength : end), singleIrregWaveTemp, "UniformOutput", false);
elseif ~isempty(singleCutOff) && singleCutOff(1) >= singleCutOff(2)
    singleIrregWave = cellfun(@(x) x(1 : tLength), singleIrregWaveTemp, "UniformOutput", false);
else
    singleIrregWave = singleIrregWaveTemp;
end

for sIndex = 1 : length(singleIrregWave)
    onIndex = find(singleIrregWave{sIndex} > 0);
    singleIrregWave{sIndex, 1}(1 : onIndex(1)-1) = [];
end

% save irregular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'offset';
if isempty(singleCutOff)
    opts.fileNameTemp = [num2str(fix((decodeDuration - repDuration) / 1000)), 's_', num2str(fix(repDuration / 1000)), 's_[ICI]_Irreg_Rep.wav'];
else
    opts.fileNameTemp = [num2str(fix(singleCutOff(1) / 1000)), 's_', num2str(fix(singleCutOff(2) / 1000)), 's_[ICI]_Irreg_Rep.wav'];
end
opts.fileNameRep = '[ICI]';
exportSoundFile(singleIrregWave, opts)


