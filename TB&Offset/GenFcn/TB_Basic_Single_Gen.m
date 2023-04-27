function sounds = TB_Basic_Single_Gen(TBOffsetParams)
parseStruct(TBOffsetParams);

    clearvars -except TBOffsetParams rIndex repNs sounds irregICISampNBase

    parseStruct(TBOffsetParams);
    rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
    repN = [];
    %% Generate Click Trains
    ICI1 = repmat(ICIBase, length(ratio), 1);
    [~, idx] = sortrows(ICI1);
    ICI1 = ICI1(idx); 
    if contains(soundType, ["Reg&Irreg", "Reg"]) % for regualr
        % generate Reg 
        sounds =RegClickGen(ICI1, S1Dur, Amp, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        for iIndex = 1 : length(sounds)
            sounds(iIndex).Name = strcat("TB_", soundType, "_ICI", strrep(num2str(sounds(iIndex).ICIs), ".", "o"), "_Dur", num2str(sounds(iIndex).Duration));
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
        Order_Std =IrregClickGen(ICI1, S1Dur, Amp, "baseICI", 4, "variance", 2, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        Order_Dev =IrregClickGen(ICI2, S2Dur, Amp, "baseICI", 4, "variance", 2, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        for iIndex = 1 : length(Order_Std)
            sounds(rIndex).Wave(iIndex+2*length(Order_Std)) = merge_S1S2("Seq_Tag", "S1_S2", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Irreg");
        end

        % generate Irreg S2-S1
        Order_Std =IrregClickGen(ICI2, S1Dur, Amp, "baseICI", 4, "variance", 2, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        Order_Dev =IrregClickGen(ICI1, S2Dur, Amp, "baseICI", 4, "variance", 2, "irregICISampNBase", irregICISampNBase, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        for iIndex = 1 : length(Order_Dev)
            sounds(rIndex).Wave(iIndex+3*length(Order_Std)) = merge_S1S2("Seq_Tag", "S2_S1", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Irreg");
        end
    end
    
    mkdir(rootPath);
    for sIndex = 1 : length(sounds)
        soundName = strcat(rootPath, "\", sounds(sIndex).Name, ".wav");
        audiowrite(soundName, sounds(sIndex).Wave, fs);
    end


if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end
end