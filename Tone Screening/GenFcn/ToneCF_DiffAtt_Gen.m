function ToneCF = ToneCF_DiffAtt_Gen(ToneCFParams)

parseStruct(ToneCFParams);

%% save folder
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));


%% generate sounds
freqPool = round(logspace(log10(freqStart), log10(freqEnd), freqN)');
T = 1/fs : 1/fs : singleDur/1000;
riseFallEnvelope = RiseFallEnve(singleDur, riseFallTime, fs);
ToneCF = cellfun(@(x) Amp*cos(2*pi*x*T), num2cell(freqPool)', "uni", false);
ToneCF = cellfun(@(x) riseFallEnvelope.*x, ToneCF, "UniformOutput", false)';
ToneCF = cellfun(@(x, y) x* att2AmpRatio(y), repmat(ToneCF, length(Attenuation), 1), num2cell(reshape(repmat(Attenuation, length(ToneCF), 1), [], 1)), "uni", false);
NameStr = cellfun(@(x, y) strcat("Tone", num2str(x), "Hz_Att",num2str(y), "dB.wav"), num2cell(repmat(freqPool, length(Attenuation), 1)),  num2cell(reshape(repmat(Attenuation, length(freqPool), 1), [], 1)), "UniformOutput", false);
sounds = cell2struct([ToneCF, NameStr], ["Wave", "Name"], 2);
%% export
mkdir(rootPath);
for sIndex = 1 : length(sounds)
    soundName = fullfile(rootPath, sounds(sIndex).Name);
    audiowrite(soundName, sounds(sIndex).Wave, fs);
end

save(fullfile(rootPath, "sounds.mat"), "sounds");


figure
plot((1:1:length(ToneCF{1}))/fs, ToneCF{1});
xlim([0, 0.2])