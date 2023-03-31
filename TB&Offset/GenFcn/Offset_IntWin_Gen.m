function sounds = Offset_IntWin_Gen(TBOffsetParams)

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
DurAll = repmat(S1Dur, length(ICIBase)*length(localChange), 1);
ICIAll = repmat(ICIs, length(localChange), 1);
changeICI = cell2mat(cellfun(@(x) ICIs*x, localChange, "UniformOutput", false));
changeICIStr = string(cellfun(@(x) ['_ChangeICI', num2str(x(1)), '_', num2str(x(2)), '_'], num2cell(changeICI, 2), "UniformOutput", false));

for lIndex = 1 : length(localChange)
    if contains(soundType, ["Reg&Irreg", "Reg"]) % for regualr
        % generate Reg S1-S2
        sounds((length(ICIs))*(lIndex-1)+1 : length(ICIs)*lIndex) = RegClickGen(ICIs, Durs, Amp, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs, "lastClick", 1, "changeICI_Head_N", changeICI_Head_N, "changeICI_Tail_N", changeICI_Tail_N, "localChange", localChange{lIndex, 1});
    end
end

%% export sounds
mkdir(rootPath)
for sIndex = 1 : length(sounds)
    soundName = strcat(rootPath, "\", "Reg_Dur-", num2str(DurAll(sIndex)), "_ICI", num2str(ICIAll(sIndex)), changeICIStr(sIndex), "HeadChange_", num2str(changeICI_Head_N), "_TailChange_", num2str(changeICI_Tail_N), ".wav");
    audiowrite(soundName, sounds(sIndex).Wave, fs);
end
if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end

end