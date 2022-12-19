% decodeDuration = 4000; % ms
% decodeICI = 15;
clearvars -except decodeDuration decodeICI decodeDurations Amp dIndex irregICISampNBase folderName;
mPath = mfilename("fullpath");
cd(fileparts(mPath));

irregRepN = 1;
regRepN = 0;

%% important parameters
opts.fs = 97656;
opts.rootPath = fullfile('..\..\ratLASounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
mkdir(opts.rootPath);

%% generate single click
opts.Amp = Amp;
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



%% export reg sound
% save regular single click train
opts.ICIName = opts.ICIs; 
opts.folderName = 'offset';
opts.fileNameTemp = [num2str(fix(decodeDuration)), 'ms_[ICI]_Reg_Rep', num2str(regRepN), '.wav'];
opts.fileNameRep = '[ICI]';
exportSoundFile(singleRegWave, opts);

