clear;
sigma = [400, 200, 100, 50, 25, 10, 2]; % ms

for dIndex = 1 : length(sigma)
    %% important parameters
    % basic
    opts(dIndex).fs = 97656;

    opts(dIndex).rootPath = fullfile('..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_Var"));
    % for continuous / seperated
    % s1ICI = 4; % ms
    % s2ICI = [4 4.01 4.02 4.03 4.06]';
    s1ICI = 4; % ms
    s2ICI = 4.06;
    singleDuration = 5000; % ms
    interval = 600; % ms
    s2CutOff = []; % if empty, do not cut

    %% generate single click
    opts(dIndex).Amp = 0.5;
    opts(dIndex).riseFallTime = 0; % ms
    opts(dIndex).clickDur = 0.2 ; % ms
    click = generateClick(opts(dIndex));

    %% for click train long term
    opts(dIndex).repN = 0; %
    opts(dIndex).click = click;
    opts(dIndex).trainLength = 100; % ms, single train
    opts(dIndex).soundLength = singleDuration; % ms, sound length, composed of N single trains
    opts(dIndex).ICIs = [s1ICI; s2ICI]; % ms

    % generate regular long term click train
    [RegWave, ~, ~, regClickTrainSampN] = generateRegClickTrain(opts(dIndex));
    s1RegWave = repmat(RegWave(1), length(RegWave) - 1, 1);
    s2RegWave = RegWave(2:end, 1);
    longTermRegWaveContinuous = mergeSingleWave(s1RegWave, s2RegWave, 0, opts(dIndex), 1);
    longTermRegWaveSepatated = mergeSingleWave(s1RegWave, s2RegWave, interval, opts(dIndex), 1); % interval unit: ms

    % generate irregular click train
    opts(dIndex).baseICI =  4; % ms
    opts(dIndex).sigmaPara = sigma(dIndex); % sigma = μ / sigmaPara
    opts(dIndex).irregICISampNBase = cell2mat(irregICISampN(opts(dIndex)));
    opts(dIndex).irregLongTermSampN = opts(dIndex).irregICISampNBase;
    [~, ~, ~, irregSampN] = generateIrregClickTrain(opts(dIndex));

    s1IrregSampN = repmat(irregSampN(1), length(irregSampN) - 1, 1);
    s1IrregRepN = regClickTrainSampN(2 : end);

    s2IrregSampN = irregSampN(2 : end);
    s2IrregRepN = repmat(regClickTrainSampN(1), length(regClickTrainSampN) - 1, 1);



    opts(dIndex).pos = 'head';
    [s1IrregWaveHeadRep, ~, s1IrregSampNHeadRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts(dIndex));
    [s2IrregWaveHeadRep, ~, s2IrregSampNHeadRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts(dIndex));

    opts(dIndex).pos = 'tail';
    [s1IrregWaveTailRep, ~, s1IrregSampNTailRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts(dIndex));
    [s2IrregWaveTailRep, ~, s2IrregSampNTailRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts(dIndex));


    longTermIrregWaveStdDevContinuous = mergeSingleWave(s1IrregWaveTailRep, s2IrregWaveHeadRep, 0, opts(dIndex));
    longTermIrregWaveStdDevSeperated = mergeSingleWave(s1IrregWaveTailRep, s2IrregWaveHeadRep, interval, opts(dIndex));



    % save continuous irregular long term click train
    opts(dIndex).ICIName = [s1ICI' s2ICI'];
    opts(dIndex).folderName = 'variance diff';
    opts(dIndex).fileNameTemp = ['[s2ICI]_IrregDevStd_sigma_', num2str(sigma(dIndex)), '.wav'];
    opts(dIndex).fileNameRep = '[s2ICI]';
    exportSoundFile({longTermIrregWaveStdDevContinuous.s1s2}, opts(dIndex))

    %% wave length for alignment
    regStdDuration = cellfun(@(x) length(x) * 1000 / opts(dIndex).fs, s1RegWave, "UniformOutput", false);
    regDevDuration = cellfun(@(x) length(x) * 1000 / opts(dIndex).fs, s2RegWave, "UniformOutput", false);
    irregStdDuration = cellfun(@(x) length(x) * 1000 / opts(dIndex).fs, s1IrregWaveTailRep, "UniformOutput", false);
    irregDevDuration = cellfun(@(x) length(x) * 1000 / opts(dIndex).fs, s2IrregWaveTailRep, "UniformOutput", false);
    stimStr = cellfun(@(x) strjoin(x, "o"), array2VectorCell(string([s1ICI', s2ICI'])), "UniformOutput", false);
    soundRealDuration = easyStruct(["stimStr", "regStdDuration", "regDevDuration", "irregStdDuration", "irregDevDuration"], ...
        [stimStr, regStdDuration, regDevDuration, irregStdDuration, irregDevDuration]);
    opts(dIndex).soundRealDuration = soundRealDuration;
    opts(dIndex).interval = interval;
    opts(dIndex).singleDuration = singleDuration;
end



