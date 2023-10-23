mPath = mfilename("fullpath");
cd(fileparts(mPath));


%% important parameters
opts.fs = 97656;
opts.rootPath = fullfile('..\..\ratLASounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
mkdir(opts.rootPath);

tLength = sum(singleCutOff) / 1000 * opts.fs;
%% generate single click

opts.Amp = 1;
opts.clickDur = evalin("base", "clickDur") ; % ms
opts.riseFallTime = 0; % ms
click = generateClick(opts);

%% for single click train
opts.click = click;
opts.trainLength = 100; % ms, single train
opts.soundLength = clickDuration; % ms, sound length, composed of N single trains
opts.ICIs = decodeICI; % ms

% generate regular click train
[singleRegWaveCopy, regDur, ~, regClickTrainSampN] = generateRegClickTrain(opts);

% generate noise
noiseWhole = -1 + 2 * rand(fix(noiseDuration / 1000 * opts.fs), 1);

for sIndex = 1 : length(singleRegWaveCopy)
    singleNoiseRegWaveCopy{sIndex} = [singleRegWaveCopy{sIndex}; click'; 0; noiseWhole*0.1];
end

%% export reg sound

% cut wave
if ~isempty(singleCutOff) && singleCutOff(1) < singleCutOff(2)
    singleNoiseRegWave = cellfun(@(x) x(end - tLength : end), singleNoiseRegWaveCopy, "UniformOutput", false);
elseif ~isempty(singleCutOff) && singleCutOff(1) >= singleCutOff(2)
    singleNoiseRegWave = cellfun(@(x) x(1 : tLength), singleNoiseRegWaveCopy, "UniformOutput", false);
else
    singleNoiseRegWave = singleNoiseRegWaveCopy;
end

for sIndex = 1 : length(singleNoiseRegWave)
    onIndex = find(singleNoiseRegWave{sIndex} > 0);
    singleNoiseRegWave{sIndex, 1}(1 : onIndex(1)-1) = [];
end

% save regular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'offset';
if isempty(singleCutOff)
    opts.fileNameTemp = [num2str(fix(clickDuration  / 1000)), 's_', num2str(fix(noiseDuration / 1000)), 's_[ICI]_Reg_Noise.wav'];
else
    opts.fileNameTemp = [num2str(fix(singleCutOff(1) / 1000)), 's_', num2str(fix(singleCutOff(2) / 1000)), 's_[ICI]_Reg_Noise.wav'];
end
opts.fileNameRep = '[ICI]';
disp("exporting decoding sounds...");
exportSoundFile(singleNoiseRegWave, opts)

%% export irreg wave
singleNoiseRegWaveTemp = cellfun(@(x) flip(x), singleNoiseRegWaveCopy, "uni", false);
% cut wave
if ~isempty(singleCutOff) && singleCutOff(1) < singleCutOff(2)
    tLength = sum(singleCutOff) / 1000 * opts.fs;
    singleNoiseRegWave = cellfun(@(x) x(end - tLength : end), singleNoiseRegWaveTemp, "UniformOutput", false);
elseif ~isempty(singleCutOff) && singleCutOff(1) >= singleCutOff(2)
    singleNoiseRegWave = cellfun(@(x) x(1 : tLength), singleNoiseRegWaveTemp, "UniformOutput", false);
else
    singleNoiseRegWave = singleNoiseRegWaveTemp;
end

% save irregular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'offset';
if isempty(singleCutOff)
    opts.fileNameTemp = [num2str(fix(clickDuration  / 1000)), 's_', num2str(fix(noiseDuration / 1000)), 's_[ICI]_Noise_Reg.wav'];
else
    opts.fileNameTemp = [num2str(fix(singleCutOff(1) / 1000)), 's_', num2str(fix(singleCutOff(2) / 1000)), 's_[ICI]_Noise_Reg.wav'];
end
opts.fileNameRep = '[ICI]';
exportSoundFile(singleNoiseRegWave, opts)


