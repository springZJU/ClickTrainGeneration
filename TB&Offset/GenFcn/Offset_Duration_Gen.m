function sounds = Offset_Duration_Gen(TBOffsetParams)

parseStruct(TBOffsetParams);

%% validate inputs
if ~isequal(numel(ratio), 1)
    error("ratio should be 1*1 !!!");
end

%% Generate Click Trains
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
repN = repRatio(1 : repNs);
ICIs = reshape(repmat(ICIBase', length(S1Dur), 1), [], 1);
Durs = repmat(S1Dur, length(ICIBase), 1);

if contains(soundType, ["Reg&Irreg", "Reg"]) % for regualr
    % generate Reg S1-S2
    sounds = RegClickGen(ICIs, Durs, Amp, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs, "lastClick", 0);
end

%% export sounds
mkdir(rootPath)
for sIndex = 1 : length(sounds)
    soundName = strcat(rootPath, "\", "Reg_Dur-", num2str(Durs(sIndex)), "_ICI", num2str(ICIs(sIndex)), ".wav");
    audiowrite(soundName, sounds(sIndex).Wave, fs);
end
if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end

end