clearvars -except Amp decodeICI folderName decodeDuration;
mPath = mfilename("fullpath");
cd(fileparts(mPath));


%% important parameters
opts.fs = 97656;
opts.rootPath = fullfile('..\..\ratLASounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
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
[singleRegWave, regDur, ~, regClickTrainSampN] = generateRegClickTrain(opts);
singleRegWave = cellfun(@(x) [x; click'], singleRegWave, "UniformOutput", false);

opts.ICIName = opts.ICIs; 
opts.folderName = 'offset';
opts.fileNameTemp = [num2str(fix(decodeDuration)), 'ms_[ICI]_Reg.wav'];
opts.fileNameRep = '[ICI]';
exportSoundFile(singleRegWave, opts)