function sounds = Perception_Gradiant_Gen(TBOffsetParams)
parseStruct(TBOffsetParams);
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

%% Generate Click Trains
ICI1 = repmat(ICIBase, length(ratio), 1);

% ascend
sounds(1).Type = "Ascend";
sounds(1).Wave = GradClickGen(ICI1, S1Dur, Amp, "fs", fs, "ICIRangeRatio", ICIRangeRatio, "Type", "ascend", "n_cycles", n_cycles, "lastClick", 1);
% descend
sounds(2).Type = "Descend";
sounds(2).Wave = GradClickGen(ICI1, S1Dur, Amp, "fs", fs, "ICIRangeRatio", ICIRangeRatio, "Type", "descend", "n_cycles", n_cycles, "lastClick", 1);
% ascend_Osci
sounds(3).Type = "Osci_Ascend";
sounds(3).Wave = GradClickGen(ICI1, S1Dur, Amp, "fs", fs, "ICIRangeRatio", ICIRangeRatio, "Type", "ascend_Osci", "n_cycles", n_cycles, "lastClick", 1);
% descend_Osci
sounds(4).Type = "Osci_Descend";
sounds(4).Wave = GradClickGen(ICI1, S1Dur, Amp, "fs", fs, "ICIRangeRatio", ICIRangeRatio, "Type", "descend_Osci", "n_cycles", n_cycles, "lastClick", 1);
% regular
sounds(5).Type = "Regular";
sounds(5).Wave = GradClickGen(ICI1, S1Dur, Amp, "fs", fs, "ICIRangeRatio", ICIRangeRatio, "Type", "regular", "n_cycles", n_cycles, "lastClick", 1);

%% export sounds
mkdir(rootPath);
for rIndex = 1 : length(sounds)
    temp = sounds(rIndex).Wave;
    for sIndex = 1 : length(temp)
        soundName = strcat(rootPath, "\", sounds(rIndex).Type, "_", num2str(temp(sIndex).ICIs), "ms_Dur", num2str(round(temp(sIndex).Duration)), "ms.wav");
        audiowrite(soundName, temp(sIndex).Wave, fs);
    end
end

if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end
end