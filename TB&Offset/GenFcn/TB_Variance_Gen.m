function sounds = TB_Variance_Gen(TBOffsetParams)
parseStruct(TBOffsetParams);
for vIndex = 1 : length(sigma)
    clearvars -except TBOffsetParams vIndex sigma sounds Var_irregICISampNBase

    parseStruct(TBOffsetParams);
    rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
    Var = sigma(vIndex);
    repN = repRatio(1 : repNs);
    sounds(vIndex).Info = strcat("Var-", num2str(Var), "_repN", string(repNs));
    %% Generate Click Trains
    ICI1 = repmat(ICIBase, length(ratio), 1);
    ICI2 = ICI1.*repmat(ratio, length(ICIBase), 1);
    [~, idx] = sortrows([ICI1, ICI2], [1, 2]);
    ICI1 = ICI1(idx); ICI2 = ICI2(idx);

    if contains(soundType, ["Reg&Irreg", "Irreg"]) % for irregualr
        if exist("Var_irregICISampNBase.mat", "file") && ~exist("Var_irregICISampNBase", "var")
            load("Var_irregICISampNBase.mat");
        end
        if ~exist("Var_irregICISampNBase", "var")
            [~, irregICISampNBase] =IrregClickGen(ICIBase, max([S1Dur, S2Dur]), Amp, "baseICI", 4, "variance", Var, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
            Var_irregICISampNBase.(strcat("Var", string(Var))) = irregICISampNBase;
        elseif~isfield(Var_irregICISampNBase, strcat("Var", string(Var)))
            [~, irregICISampNBase] =IrregClickGen(ICIBase, max([S1Dur, S2Dur]), Amp, "baseICI", 4, "variance", Var, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
            Var_irregICISampNBase.(strcat("Var", string(Var))) = irregICISampNBase;
        else
            irregICISampNBase = Var_irregICISampNBase.(strcat("Var", string(Var)));
        end


        % generate Irreg S1-S2
        Order_Std = IrregClickGen(ICI1, S1Dur, Amp, "baseICI", 4, "variance", Var, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        Order_Dev =IrregClickGen(ICI2, S2Dur, Amp, "baseICI", 4, "variance", Var, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        for iIndex = 1 : length(Order_Std)
            sounds(vIndex).Wave(iIndex) = merge_S1S2("Seq_Tag", "S1_S2", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Irreg");
        end

        % generate Irreg S2-S1
        Order_Std =IrregClickGen(ICI2, S1Dur, Amp, "baseICI", 4, "variance", Var, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        Order_Dev =IrregClickGen(ICI1, S2Dur, Amp, "baseICI", 4, "variance", Var, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        for iIndex = 1 : length(Order_Dev)
            sounds(vIndex).Wave(iIndex+length(Order_Std)) = merge_S1S2("Seq_Tag", "S2_S1", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Irreg");
        end
    end

    temp = sounds(vIndex).Wave;
    mkdir(rootPath);
    for sIndex = 1 : length(temp)
        soundName = strcat(rootPath, "\", temp(sIndex).Name, sounds(vIndex).Info, ".wav");
        audiowrite(soundName, temp(sIndex).Wave, fs);
    end

end
save("Var_irregICISampNBase.mat", "Var_irregICISampNBase", "-mat");
if  saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end
end