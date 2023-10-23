
clearvars -except singleDuration s2CutOff ICIBase ratio Amp folderName repNs rIndex irregICISampNBase
mPath = mfilename("fullpath");
cd(fileparts(mPath));

%% important parameters
opts.fs = 97656;
% for continuous / seperated

s1ICI = repmat(ICIBase, 1, length(ratio)); % ms
s2ICI = reshape(ICIBase' * ratio, 1, []);

interval = 0; % ms
opts.rootPath = fullfile('..\..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
mkdir(opts.rootPath);

%% generate single click
opts.Amp = Amp;
opts.AmpS1 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s1ICI), "UniformOutput", false);
opts.AmpS2 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s2ICI), "UniformOutput", false);
opts.riseFallTime = 0; % ms
opts.clickDur = evalin("base", "clickDur") ; % ms
click = generateClick(opts);

%% for click train long term
opts.repN = repNs(rIndex); % 
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


%% wave length for alignment
regStdDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s1RegWave, "UniformOutput", false);
regDevDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s2RegWave, "UniformOutput", false);


stimStr = cellfun(@(x) strjoin(x, "o"), array2VectorCell(string([s1ICI', s2ICI'])), "UniformOutput", false);
soundRealDuration = easyStruct(["stimStr", "regStdDuration", "regDevDuration"], ...
    [stimStr, regStdDuration, regDevDuration]);
opts.soundRealDuration = soundRealDuration;
opts.interval = interval;
opts.singleDuration = singleDuration;

save(fullfile(opts.rootPath, ['opts.mat']), 'opts');

