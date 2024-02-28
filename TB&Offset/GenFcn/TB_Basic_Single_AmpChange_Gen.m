function sounds = TB_Basic_Single_AmpChange_Gen(TBOffsetParams)
parseStruct(TBOffsetParams);
gradN = [0.2 0.35 0.4 0.5 0.65 0.75 0.9];
for rIndex = 1 : length(gradN)
    clearvars -except TBOffsetParams rIndex gradN sounds irregICISampNBase

    parseStruct(TBOffsetParams);
    rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

    repN = [];
    sounds(rIndex).Info = strcat("0o5-gard", string(gradN(rIndex)));

    %% Generate Click Trains
    ICI1 = repmat(ICIBase, length(ratio), 1);
    ICI2 = ICI1.*repmat(ratio, length(ICIBase), 1);
    [~, idx] = sortrows([ICI1, ICI2], [1, 2]);
    ICI1 = ICI1(idx); ICI2 = ICI2(idx);
    if contains(soundType, ["Reg&Irreg", "Reg"]) % for regualr
        % generate Reg S1-S2
        Order_Std =RegClickGen(ICI1, S1Dur, Amp, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs, "lastClick", lastClick , "clickType", clickType);
        for iIndex = 1 : length(Order_Std)
            sounds(rIndex).Wave(iIndex) = Ampgrad_Gen(Order_Std(iIndex), Amp, gradN(rIndex));    
        end
    end

    if contains(soundType, ["Reg&Irreg", "Irreg"]) % for irregualr
%         if exist("irregICISampNBase.mat", "file")
%             load("irregICISampNBase.mat");
%         end
        if ~exist("irregICISampNBase", "var")
            [~, irregICISampNBase] =IrregClickGen(ICIBase, max([S1Dur, S2Dur]), Amp, "baseICI", 4, "variance", 2, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
            save("irregICISampNBase.mat","irregICISampNBase", "-mat");
        end
        % generate Irreg S1-S2
        Order_Std =IrregClickGen(ICI1, S1Dur, Amp, "baseICI", 4, "variance", 2, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs, "clickType", clickType);
        Order_Dev =IrregClickGen(ICI2, S2Dur, Amp, "baseICI", 4, "variance", 2, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs, "lastClick", lastClick , "clickType", clickType);
        for iIndex = 1 : length(Order_Std)
            sounds(rIndex).Wave(iIndex+2*length(Order_Std)) = merge_S1S2("Seq_Tag", "S1_S2", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Irreg");
        end

        % generate Irreg S2-S1
        Order_Std =IrregClickGen(ICI2, S1Dur, Amp, "baseICI", 4, "variance", 2, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs, "clickType", clickType);
        Order_Dev =IrregClickGen(ICI1, S2Dur, Amp, "baseICI", 4, "variance", 2, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs, "lastClick", lastClick , "clickType", clickType);
        for iIndex = 1 : length(Order_Dev)
            sounds(rIndex).Wave(iIndex+3*length(Order_Std)) = merge_S1S2("Seq_Tag", "S2_S1", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Irreg");
        end
    end
     temp = sounds(rIndex).Wave;
    mkdir(rootPath);
    for sIndex = 1 : length(temp)
        soundName = strcat(rootPath, "\", temp(sIndex).Name, "_", sounds(rIndex).Info, ".wav");
        audiowrite(soundName, temp(sIndex).Wave, fs);
    end

end
if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end
end