function sounds = ThreeScales_Skew_Gen(TBOffsetParams)
parseStruct(TBOffsetParams);
for vIndex = 1 : length(sigma)
    clearvars -except TBOffsetParams vIndex sigma sounds TB_Var_irregICISampNBase

    parseStruct(TBOffsetParams);
    rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
    Var = sigma{vIndex};
    repN = repRatio(1 : repNs);
    sounds(vIndex).Info = strcat("repN", string(repNs));
    %% Generate Click Trains
    if contains(soundType, ["Reg&Irreg", "Irreg"]) % for irregualr
        if exist(".\TB_Var_irregICISampNBase.mat", "file") && ~exist("TB_Var_irregICISampNBase", "var")
            load(".\TB_Var_irregICISampNBase.mat");
        end
        if ~exist("TB_Var_irregICISampNBase", "var") || ~isfield(TB_Var_irregICISampNBase, strcat("Var", string(Var)))
            [~, irregICISampNBase] =IrregClickGen(ICIBase, max([S1Dur, S2Dur]), Amp, "ICIRangeRatio", ICIRangeRatio, "baseICI", 4, "variance", Var, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
            TB_Var_irregICISampNBase.(strcat("Var", string(Var))) = irregICISampNBase;
        else
            irregICISampNBase = TB_Var_irregICISampNBase.(strcat("Var", string(Var)));
        end
        opts.dataRange  = ICIBase * ICIRangeRatio;
        opts.targetMean = ICIBase;
        opts.targetStd  = ICIBase ./ Var;
        opts.skewType   = skewType;
        opts.fs         = fs;
        opts.basicICI   = 4;
        for skewIdx = 1 : length(skewBase)
            opts.skewBase = skewBase(skewIdx);
            skewedSampleN{skewIdx, 1} = skewGeneration(opts, irregICISampNBase);
        % generate Irreg S1-S2
            Order_Std = IrregClickGen(ICIBase, S1Dur, Amp, "clickType", clickType, "baseICI", 4, "variance", Var, "ICIRangeRatio", ICIRangeRatio, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
            Order_Dev = IrregClickGen(ICIBase, S2Dur, Amp, "clickType", clickType, "baseICI", 4, "variance", Var, "ICIRangeRatio", ICIRangeRatio, "irregICISampNBase", skewedSampleN{skewIdx, 1}, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
            sounds(vIndex).Wave(skewIdx) = merge_S1S2("Seq_Tag", "S1_S2", "Std_Wave", Order_Std, "Dev_Wave", Order_Dev, "soundType", "Irreg");
            varInfo(skewIdx) = strcat("Var-", num2str(Var), "_Norm-SkewBase", num2str(skewBase(skewIdx)));

        % generate Irreg S2-S1
            Order_Std =IrregClickGen(ICIBase, S1Dur, Amp, "clickType", clickType, "baseICI", 4, "variance", Var, "ICIRangeRatio", ICIRangeRatio, "irregICISampNBase", skewedSampleN{skewIdx, 1}, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
            Order_Dev =IrregClickGen(ICIBase, S2Dur, Amp, "clickType", clickType, "baseICI", 4, "variance", Var, "ICIRangeRatio", ICIRangeRatio, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
            sounds(vIndex).Wave(skewIdx+length(skewBase)) = merge_S1S2("Seq_Tag", "S2_S1", "Std_Wave", Order_Std, "Dev_Wave", Order_Dev, "soundType", "Irreg");
            varInfo(skewIdx+length(skewBase)) = strcat("Var-", num2str(Var), "_SkewBase", num2str(skewBase(skewIdx)), "-Norm");
        end
    end

    temp = sounds(vIndex).Wave;
    mkdir(rootPath);
    for sIndex = 1 : length(temp)
        soundName = strcat(rootPath, "\", varInfo(sIndex), "_", temp(sIndex).Name, "_", sounds(vIndex).Info,  ".wav");
        audiowrite(soundName, temp(sIndex).Wave, fs);
    end

end
save(".\TB_Var_irregICISampNBase.mat", "TB_Var_irregICISampNBase", "-mat");
if  saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end
end