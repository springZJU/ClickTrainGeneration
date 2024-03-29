function Noise = Noise_DiffAtt_Gen(ToneCFParams)

parseStruct(ToneCFParams);

%% save folder
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));


%% generate sounds
for dIndex = 1 : length(singleDur)
    T = 1/fs : 1/fs : singleDur(dIndex)/1000;
    riseFallEnvelope = RiseFallEnve(singleDur(dIndex), riseFallTime, fs);
    Noise = riseFallEnvelope.* (2*rand(1, length(T))-1);
    Noise = cellfun(@(x) Noise* att2AmpRatio(x), num2cell(Attenuation), "uni", false);
    NameStr = cellfun(@(x) strcat("Noise_Att",num2str(x), "dB.wav"),  num2cell(Attenuation), "UniformOutput", false);
    sounds(dIndex) = cell2struct([Noise, NameStr], ["Wave", "Name"], 2);
end
%% export
mkdir(rootPath);
for sIndex = 1 : length(sounds)
    soundName = strcat(rootPath, "\Dur_", num2str(singleDur(sIndex)), "ms",sounds(sIndex).Name);
    audiowrite(soundName, sounds(sIndex).Wave, fs);
end

save(fullfile(rootPath, "sounds.mat"), "sounds");