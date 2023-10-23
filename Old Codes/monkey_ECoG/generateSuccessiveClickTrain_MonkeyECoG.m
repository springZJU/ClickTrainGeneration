clearvars -except singleDuration folderName Amp ICIBase ratio successiveDuration

mPath = mfilename("fullpath");
cd(fileparts(mPath));
%% important parameters
% basic
opts.fs = 97656;
    opts.rootPath = fullfile('..\..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

mkdir(opts.rootPath);

% for continuous / seperated
s1ICI = repmat(ICIBase, 1, length(ratio)); % ms
s2ICI = reshape(ICIBase' * ratio, 1, []);

% singleDuration = 200; % ms

s2CutOff = []; % if empty, do not cut
interval = 0; % ms


%% generate single click
opts.Amp = Amp;
opts.AmpS1 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s1ICI), "UniformOutput", false);
opts.AmpS2 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts.Amp, 2), num2cell(s2ICI), "UniformOutput", false);
opts.riseFallTime = 0; % ms
opts.clickDur = evalin("base", "clickDur") ; % ms
click = generateClick(opts);


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
opts.singleDuration = singleDuration;

save(fullfile(opts.rootPath, 'opts'), 'opts');

