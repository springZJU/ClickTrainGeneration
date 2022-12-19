function sounds = Offset_Variance_Gen(TBOffsetParams)

parseStruct(TBOffsetParams);

%% validate inputs
if ~isequal(numel(ratio), 1)
    error("ratio should be 1*1 !!!");
end
parseStruct(TBOffsetParams);
%% Generate Click Trains
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
repN = repRatio(1 : repNs);
ICIs = reshape(repmat(ICIBase', length(sigma), 1), [], 1);
Vars = repmat(sigma, length(ICIBase), 1);
for vIndex = 1 : length(ICIs)
    Var = Vars(vIndex);
    if contains(soundType, ["Reg&Irreg", "Irreg"]) % for irregualr
        if exist("Var_irregICISampNBase.mat", "file") && ~exist("Var_irregICISampNBase", "var")
            load("Var_irregICISampNBase.mat");
        end
        if ~exist("Var_irregICISampNBase", "var")
            [~, irregICISampNBase] =IrregClickGen(ICIBase, max([S1Dur, S2Dur]), Amp, "baseICI", 4, "variance", Var, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
            Var_irregICISampNBase.(strcat("Var", string(Var))) = irregICISampNBase;
        elseif ~isfield(Var_irregICISampNBase, strcat("Var", string(Var)))
            [~, irregICISampNBase] =IrregClickGen(ICIBase, max([S1Dur, S2Dur]), Amp, "baseICI", 4, "variance", Var, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
            Var_irregICISampNBase.(strcat("Var", string(Var))) = irregICISampNBase;
        else
            irregICISampNBase = Var_irregICISampNBase.(strcat("Var", string(Var)));
        end
    end
    sounds(vIndex) = IrregClickGen(ICIs(vIndex), S1Dur, Amp, "baseICI", 4, "variance", Var, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs, "lastClick", 1);
end
%% export sounds
mkdir(rootPath)
for sIndex = 1 : length(sounds)
    soundName = strcat(rootPath, "\", "Irreg_Dur-", num2str(S1Dur), "_ICI", num2str(ICIs(sIndex)), "_Var", num2str(Vars(sIndex)),  ".wav");
    audiowrite(soundName, sounds(sIndex).Wave, fs);
end
save("Var_irregICISampNBase.mat", "Var_irregICISampNBase", "-mat");

if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end

end