function sounds = ThreeScales_Variance_Gen(TBOffsetParams)
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
        for index = 1 : length(Var)
            if ~exist("TB_Var_irregICISampNBase", "var")
                [~, irregICISampNBase{index, 1}] =IrregClickGen(ICIBase, max([S1Dur, S2Dur]), Amp, "ICIRangeRatio", ICIRangeRatio, "baseICI", 4, "variance", Var(index), "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
                TB_Var_irregICISampNBase.(strcat("Var", string(Var(index)))) = irregICISampNBase{index, 1};
            elseif~isfield(TB_Var_irregICISampNBase, strcat("Var", strrep(string(Var(index)), ".", "o")))
                [~, irregICISampNBase{index, 1}] =IrregClickGen(ICIBase, max([S1Dur, S2Dur]), Amp, "ICIRangeRatio", ICIRangeRatio, "baseICI", 4, "variance", Var(index), "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
                TB_Var_irregICISampNBase.(strcat("Var", strrep(string(Var(index)), ".", "o"))) = irregICISampNBase{index, 1};
            else
                irregICISampNBase{index, 1} = TB_Var_irregICISampNBase.(strcat("Var", strrep(string(Var(index)), ".", "o")));
            end
        end



        % generate Irreg S1-S2
        Order_Std = IrregClickGen(ICIBase, S1Dur, Amp, "clickType", clickType, "baseICI", 4, "variance", Var(1), "ICIRangeRatio", ICIRangeRatio, "irregICISampNBase", irregICISampNBase{1}, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        Order_Dev =IrregClickGen(ICIBase, S2Dur, Amp, "clickType", clickType, "baseICI", 4, "variance", Var(2), "ICIRangeRatio", ICIRangeRatio, "irregICISampNBase", irregICISampNBase{2}, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        for iIndex = 1 : length(Order_Std)
            sounds(vIndex).Wave(iIndex) = merge_S1S2("Seq_Tag", "S1_S2", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Irreg");
            varInfo(iIndex) = strcat("Var-", num2str(Var(1)), "_Var-", num2str(Var(2)));
        end

        % generate Irreg S2-S1
        Order_Std =IrregClickGen(ICIBase, S1Dur, Amp, "clickType", clickType, "baseICI", 4, "variance", Var(2), "ICIRangeRatio", ICIRangeRatio, "irregICISampNBase", irregICISampNBase{2}, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        Order_Dev =IrregClickGen(ICIBase, S2Dur, Amp, "clickType", clickType, "baseICI", 4, "variance", Var(1), "ICIRangeRatio", ICIRangeRatio, "irregICISampNBase", irregICISampNBase{1}, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        for iIndex = 1 : length(Order_Dev)
            sounds(vIndex).Wave(iIndex+length(Order_Std)) = merge_S1S2("Seq_Tag", "S2_S1", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Irreg");
            varInfo(iIndex+length(Order_Std)) = strcat("Var-", num2str(Var(2)), "_Var-", num2str(Var(1)));
        end
    end

    temp = sounds(vIndex).Wave;
    mkdir(rootPath);
    for sIndex = 1 : length(temp)
        soundName = strcat(rootPath, "\", temp(sIndex).Name, "_", sounds(vIndex).Info, "_", varInfo(sIndex), ".wav");
        audiowrite(soundName, temp(sIndex).Wave, fs);
    end

end
save(".\TB_Var_irregICISampNBase.mat", "TB_Var_irregICISampNBase", "-mat");
if  saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end
end