clear;
sigma = [200, 100, 50, 25, 10]; % ms

for dIndex = 1 : length(sigma)
    %% important parameters
    % basic
    opts(dIndex).fs = 97656;

    opts(dIndex).rootPath = fullfile('..\..\ratSounds', strcat(datestr(now, "yyyy-mm-dd"), "_Var_8"));
    % for continuous / seperated
    s1ICI = [8]; % ms
    s2ICI =s1ICI*1.5;
    singleDuration = 3000; % ms
    interval = 600; % ms
    s2CutOff = 1000; % if empty, do not cut

    %% generate single click
    opts(dIndex).Amp = 0.1;
    opts(dIndex).AmpS1 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts(dIndex).Amp, 2), num2cell(s1ICI), "UniformOutput", false);
    opts(dIndex).AmpS2 = cellfun(@(x, y) normalizeClickTrainSPL(4, x, opts(dIndex).Amp, 2), num2cell(s2ICI), "UniformOutput", false);    opts(dIndex).riseFallTime = 0; % ms
    opts(dIndex).clickDur = 0.2 ; % ms
    click = generateClick(opts(dIndex));

    %% for click train long term
    opts(dIndex).repN = 0; %
    opts(dIndex).click = click;
    opts(dIndex).trainLength = 100; % ms, single train
    opts(dIndex).soundLength = singleDuration; % ms, sound length, composed of N single trains
    opts(dIndex).ICIs = reshape([s1ICI; s2ICI], [], 1 ); % ms


    % generate regular long term click train
    [RegWave, ~, ~, regClickTrainSampN] = generateRegClickTrain(opts(dIndex));
    s1RegWave = RegWave(1 : 2 : end);
    s2RegWave = RegWave(2 : 2 : end);
    longTermRegWaveContinuous = mergeSingleWave(s1RegWave, s2RegWave, 0, opts(dIndex), 1);
    longTermRegWaveSepatated = mergeSingleWave(s1RegWave, s2RegWave, interval, opts(dIndex), 1); % interval unit: ms

    % generate irregular click train
    opts(dIndex).baseICI =  s1ICI; % ms
    opts(dIndex).sigmaPara = sigma(dIndex); % sigma = μ / sigmaPara
    opts(dIndex).irregICISampNBase = cell2mat(irregICISampN(opts(dIndex)));
    opts(dIndex).irregLongTermSampN = opts(dIndex).irregICISampNBase;
    [~, ~, ~, irregSampN] = generateIrregClickTrain(opts(dIndex));

    s1IrregSampN = irregSampN(1 : 2 : end);
    s1IrregRepN = regClickTrainSampN(2 : 2 : end);

    s2IrregSampN = irregSampN(2 : 2 : end);
    s2IrregRepN = regClickTrainSampN(1 : 2 : end);



    opts(dIndex).pos = 'head';
    [s1IrregWaveHeadRep, ~, s1IrregSampNHeadRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts(dIndex));
    [s2IrregWaveHeadRep, ~, s2IrregSampNHeadRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts(dIndex));

    opts(dIndex).pos = 'tail';
    [s1IrregWaveTailRep, ~, s1IrregSampNTailRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts(dIndex));
    [s2IrregWaveTailRep, ~, s2IrregSampNTailRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts(dIndex));



    longTermIrregWaveStdDevContinuous = mergeSingleWave(s1IrregWaveTailRep, s2IrregWaveHeadRep, 0, opts(dIndex), 0, s2CutOff);
%     longTermIrregWaveStdDevSeperated = mergeSingleWave(s1IrregWaveTailRep, s2IrregWaveHeadRep, interval, opts(dIndex), 0, s2CutOff);

    % normalize S2 SPL to S1 SPL
    for sIndex = 1 : length(s1RegWave)
        s1IrregWaveTailRep{sIndex} = opts(dIndex).AmpS1{sIndex} / opts(dIndex).Amp * s1IrregWaveTailRep{sIndex} ;
        s2IrregWaveHeadRep{sIndex} = opts(dIndex).AmpS2{sIndex} / opts(dIndex).Amp * s2IrregWaveHeadRep{sIndex} ;
    end
    longTermIrregWaveStdDevContinuousNorm = mergeSingleWave(s1IrregWaveTailRep, s2IrregWaveHeadRep, 0, opts(dIndex), 0, s2CutOff);
%     longTermIrregWaveStdDevSeperatedNorm = mergeSingleWave(opts(dIndex).AmpS1' ./ opts(dIndex).Amp * s1IrregWaveTailRep, opts(dIndex).AmpS2' ./ opts(dIndex).Amp * s2IrregWaveHeadRep, interval, opts(dIndex), 0, );



    % save continuous irregular long term click train
    opts(dIndex).ICIName = [s1ICI' s2ICI'];
    opts(dIndex).folderName = 'variance diff';
    opts(dIndex).fileNameTemp = ['[s2ICI]_IrregDevStd_sigma_', num2str(sigma(dIndex)), '.wav'];
    opts(dIndex).fileNameRep = '[s2ICI]';
    exportSoundFile({longTermIrregWaveStdDevContinuous.s1s2}, opts(dIndex))

    % save normalized continuous irregular long term click train
    opts(dIndex).ICIName = [s1ICI' s2ICI'];
    opts(dIndex).folderName = 'variance diff NormSqrt';
    opts(dIndex).fileNameTemp = ['[s2ICI]_IrregDevStd_sigma_', num2str(sigma(dIndex)), '.wav'];
    opts(dIndex).fileNameRep = '[s2ICI]';
    exportSoundFile({longTermIrregWaveStdDevContinuousNorm.s1s2}, opts(dIndex))

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
save(fullfile(opts(dIndex).rootPath, 'opts.mat'), 'opts');



