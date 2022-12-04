function waveOutput = RegClickGen(ICIs, Duration, Amp)

%% generate single click
opts.fs = 97656;
opts.Amp = Amp;
opts.clickDur = 0.2 ; % ms
opts.riseFallTime = 0; % ms
click = generateClick(opts);

%% for single click train
opts.click = click;
opts.trainLength = 100; % ms, single train
opts.soundLength = Duration; % ms, sound length, composed of N single trains
opts.ICIs = ICIs; % ms
singleRegWave = generateRegClickTrain(opts);

c_ICIs = num2cell(ICIs)';
c_Wave = singleRegWave;
c_OnsetIdx = cellfun(@(x) [1; find(diff(x) > 0) + 1], singleRegWave, "uni", false);
c_SampN = cellfun(@(x) diff(x), c_OnsetIdx, "uni", false);
c_LastClickOnset = cellfun(@(x) x(end)/opts.fs*1000, c_OnsetIdx, "UniformOutput", false);
c_Duration = cellfun(@(x) length(x)/opts.fs*1000, singleRegWave, "UniformOutput", false);
c_fs = num2cell(repmat(opts.fs, length(ICIs), 1));
waveOutput = cell2struct([c_ICIs, c_Wave, c_fs, c_OnsetIdx, c_SampN, c_LastClickOnset, c_Duration], ["ICIs", "Wave", "fs", "OnsetIdx", "SampN", "LastClickOnset", "Duration"], 2);
end