function soundParse = checkClickTrainFcn(rootpath, thr, minInterval)
files = dir([char(rootpath), '\*.wav']);
[soundWave, fs] = cellfun(@(x) audioread(fullfile(rootpath, x)), {files.name}', "UniformOutput", false);
T = cellfun(@(x, sound) 1/x:1/x:length(sound)/x, fs, soundWave, "UniformOutput", false);
[~, clickT] = cellfun(@(t, sound) findpeaks(sound, t' * 1000, "MinPeakHeight", thr, "MinPeakDistance", minInterval), T, soundWave, "UniformOutput", false);
ICI = cellfun(@diff, clickT, "UniformOutput", false);
soundLength = cellfun(@(x) x(end), clickT, "UniformOutput", false);

soundParse = cell2struct([{files.name}', soundWave, fs, clickT, ICI, soundLength], ...
                         ["name", "y1", "fs", "clickT", "ICI", "soundLength"], 2);
end