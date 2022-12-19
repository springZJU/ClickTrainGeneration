function sounds = Offset_Screening_Gen(TBOffsetParams)
parseStruct(TBOffsetParams);
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

repN = repRatio(1 : repNs);
%% Generate Click Trains
if contains(soundType, ["Reg&Irreg", "Reg"]) % for regualr
    % generate Reg S1-S2
    sounds = RegClickGen(ICIBase, S1Dur, Amp, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs, "lastClick", 1);
end


%% export sounds
mkdir(rootPath)
for sIndex = 1 : length(sounds)
    soundName = strcat(rootPath, "\", "Reg_Dur-", num2str(S1Dur), "_ICI", num2str(sounds(sIndex).ICIs), ".wav");
    audiowrite(soundName, sounds(sIndex).Wave, fs);
end
if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end

end