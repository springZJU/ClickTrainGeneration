clearvars -except  singleDuration s1CutOff s2CutOff ICIBase ratio Amp folderName
mPath = mfilename("fullpath");
cd(fileparts(mPath));

for dIndex = 1 : length(singleDuration)
    clearvars -except singleDuration s1CutOff s2CutOff opts dIndex ICIBase ratio Amp folderName; clc
    %% important parameters
    opts(dIndex).fs = 97656;
    % for continuous / seperated

    s1ICI = repmat(ICIBase, 1, length(ratio)); % ms
    s2ICI = reshape(ICIBase' * ratio, 1, []);
    interval = 0; % ms
    opts(dIndex).rootPath = fullfile('..\..\ratLASounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
    mkdir(opts(dIndex).rootPath);

    %% generate single click
    opts(dIndex).Amp = Amp;
    opts(dIndex).AmpS1 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts(dIndex).Amp, 2), num2cell(s1ICI), "UniformOutput", false);
    opts(dIndex).AmpS2 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts(dIndex).Amp, 2), num2cell(s2ICI), "UniformOutput", false);
    opts(dIndex).riseFallTime = 0; % ms
    opts(dIndex).clickDur = 0.2 ; % ms
    click = generateClick(opts(dIndex));

    %% for click train long term
    opts(dIndex).repN = 0; %
    opts(dIndex).click = click;
    opts(dIndex).trainLength = 100; % ms, single train
    opts(dIndex).soundLength = singleDuration(dIndex); % ms, sound length, composed of N single trains
    opts(dIndex).ICIs = reshape([s1ICI; s2ICI], [], 1 ); % ms

    %% regular
    % generate regular long term click train
    [RegWave, ~, ~, regClickTrainSampN] = generateRegClickTrain(opts(dIndex));
    s1RegWave = RegWave(1 : 2 : end);
    s2RegWave = RegWave(2 : 2 : end);

    longTermRegWaveContinuous = mergeSingleWave(s1RegWave, s2RegWave, 0, opts(dIndex), 1, s2CutOff{dIndex}, s1CutOff{dIndex});

    % normalize S2 SPL to S1 SPL
%     longTermRegWaveContinuousNorm = mergeSingleWave(s1RegWave, s2RegWave, 0, opts, 1, s2CutOff{dIndex}, s1CutOff{dIndex});
for sIndex = 1 : length(s1RegWave)
    s1RegWave{sIndex} = opts(dIndex).AmpS1{sIndex} / opts(dIndex).Amp * s1RegWave{sIndex} ;
    s2RegWave{sIndex} = opts(dIndex).AmpS2{sIndex} / opts(dIndex).Amp * s2RegWave{sIndex} ;
end
longTermRegWaveContinuousNorm = mergeSingleWave(s1RegWave, s2RegWave, 0, opts(dIndex), 1, s2CutOff{dIndex}, s1CutOff{dIndex});


    singleDuration(1) = 500;
    % save continuous regular long term click train
    opts(dIndex).ICIName = [s1ICI' s2ICI'];
    opts(dIndex).folderName = 'interval 0';
    opts(dIndex).fileNameTemp = [num2str(singleDuration(dIndex)/1000), 's_[s2ICI]_RegStdDev.wav'];
    opts(dIndex).fileNameRep = '[s2ICI]';
    disp("exporting regular click train sounds...");
    exportSoundFile({longTermRegWaveContinuous.s1s2}, opts(dIndex))
    opts(dIndex).folderName = 'interval 0 Norm Sqrt';
    exportSoundFile({longTermRegWaveContinuousNorm.s1s2}, opts(dIndex))

    % save continuous regular long term click train
    opts(dIndex).ICIName = [s1ICI' s2ICI'];
    opts(dIndex).folderName = 'interval 0';
    opts(dIndex).fileNameTemp = [num2str(singleDuration(dIndex)/1000), 's_[s2ICI]_RegDevStd.wav'];
    opts(dIndex).fileNameRep = '[s2ICI]';
    exportSoundFile({longTermRegWaveContinuous.s2s1}, opts(dIndex))
    opts(dIndex).folderName = 'interval 0 Norm Sqrt';
    exportSoundFile({longTermRegWaveContinuousNorm.s2s1}, opts(dIndex))






    %% wave length for alignment
    regStdDuration = cellfun(@(x) length(x) * 1000 / opts(dIndex).fs, s1RegWave, "UniformOutput", false);
    regDevDuration = cellfun(@(x) length(x) * 1000 / opts(dIndex).fs, s2RegWave, "UniformOutput", false);


    stimStr = cellfun(@(x) strjoin(x, "o"), array2VectorCell(string([s1ICI', s2ICI'])), "UniformOutput", false);
    soundRealDuration = easyStruct(["stimStr", "regStdDuration", "regDevDuration"], ...
        [stimStr, regStdDuration, regDevDuration]);
    opts(dIndex).soundRealDuration = soundRealDuration;
    opts(dIndex).interval = interval;
    opts(dIndex).singleDuration = singleDuration(dIndex);
end
save(fullfile(opts(dIndex).rootPath, 'opts.mat'), 'opts');

