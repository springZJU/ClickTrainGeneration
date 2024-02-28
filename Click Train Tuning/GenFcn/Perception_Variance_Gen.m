function sounds = Perception_Variance_Gen(TBOffsetParams)

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
    IrregSampN_Str = strrep(strcat("Offset_Var_irregICISampNBase_", num2str(ICIRangeRatio(1)), "_", num2str(ICIRangeRatio(2))), ".", "o");
    IrregSampN_MAT_Str = strcat(IrregSampN_Str, ".mat");
    if contains(soundType, ["Reg&Irreg", "Irreg"]) % for irregualr
        if exist(IrregSampN_MAT_Str, "file") && ~exist("Offset_Var_irregICISampNBase", "var")
            load(IrregSampN_MAT_Str);
        end
        if ~exist("Offset_Var_irregICISampNBase", "var")
            [~, irregICISampNBase] =IrregClickGen(ICIBase, max([S1Dur, S2Dur]), Amp, "baseICI", 4, "variance", Var, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs, "ICIRangeRatio", ICIRangeRatio);
            Offset_Var_irregICISampNBase.(strcat("Var", string(Var))) = irregICISampNBase;
        elseif ~isfield(Offset_Var_irregICISampNBase, strcat("Var", string(Var)))
            [~, irregICISampNBase] =IrregClickGen(ICIBase, max([S1Dur, S2Dur]), Amp, "baseICI", 4, "variance", Var, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs, "ICIRangeRatio", ICIRangeRatio);
            Offset_Var_irregICISampNBase.(strcat("Var", string(Var))) = irregICISampNBase;
        else
            irregICISampNBase = Offset_Var_irregICISampNBase.(strcat("Var", string(Var)));
        end
    end
    sounds(vIndex) = IrregClickGen(ICIs(vIndex), S1Dur, Amp, "baseICI", 4, "variance", Var, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs, "lastClick", 1, "ICIRangeRatio", ICIRangeRatio);
end
%% export sounds
mkdir(rootPath)
for sIndex = 1 : length(sounds)
    soundName = strcat(rootPath, "\", "Irreg_Dur-", num2str(S1Dur), "_ICI", num2str(ICIs(sIndex)), "_Var", num2str(Vars(sIndex)),  ".wav");
    audiowrite(soundName, sounds(sIndex).Wave, fs);
end
save(IrregSampN_MAT_Str, "Offset_Var_irregICISampNBase", "-mat");

if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end

end