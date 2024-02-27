function sounds = Offset_Jitter_Gen(TBOffsetParams)
parseStruct(TBOffsetParams);
for jIndex = 1 : length(Jitter)
    clearvars -except TBOffsetParams rIndex repNs sounds  Jitter jIndex

    parseStruct(TBOffsetParams);
    rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
    jitterTemp = Jitter{jIndex};

    %% Generate Click Trains
    if contains(soundType, ["Reg&Irreg", "Irreg"]) % for regualr
    for bIndex = 1 :length(ICIBase)
        sounds((jIndex-1)*length(ICIBase) + bIndex).Info = strcat("Jitter", string(Jitter{jIndex}(1)), "-", string(Jitter{jIndex}(2)), "_ICI_", num2str(ICIBase(bIndex)), "ms");
        sounds((jIndex-1)*length(ICIBase) + bIndex).Wave =JitterClickGen(ICIBase(bIndex), S1Dur, Amp,  "repTail", repTail*repRatioTail, "fs", fs, "Jitter", jitterTemp, "JitterMethod", "EvenOdd", "lastClick", lastClick, "clickType", clickType);
    end
    end
end

mkdir(rootPath);
for sIndex = 1 : length(sounds)
        soundName = strcat(rootPath, "\", sounds(sIndex).Info, "_Last", num2str(length(repRatio)) , ".wav");
        audiowrite(soundName, sounds(sIndex).Wave.Wave, fs);
end


if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end
end