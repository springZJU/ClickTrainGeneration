function sounds = TB_Duration_Gen(TBOffsetParams)
parseStruct(TBOffsetParams);
    rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

for dIndex = 1 : length(S1Dur)
    clearvars -except TBOffsetParams dIndex repNs sounds irregICISampNBase rootPath

    parseStruct(TBOffsetParams);
    sounds(dIndex).Info = strcat("Dur", string(S1Dur(dIndex)), "_");



    %% Generate Click Trains
    ICI1 = repmat(ICIBase, length(ratio), 1);
    ICI2 = ICI1.*repmat(ratio, length(ICIBase), 1);
    [~, idx] = sortrows([ICI1, ICI2], [1, 2]);
    ICI1 = ICI1(idx); ICI2 = ICI2(idx);
    if contains(soundType, ["Reg&Irreg", "Reg"]) % for regualr
        % generate Reg S1-S2
        Order_Std =RegClickGen(ICI1, S1Dur(dIndex), Amp, "fs", fs);
        Order_Dev =RegClickGen(ICI2, S2Dur, Amp, "fs", fs);
        for iIndex = 1 : length(Order_Std)
            sounds(dIndex).Wave(iIndex) = merge_S1S2("Seq_Tag", "S1_S2", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Reg");
        end

        % generate Reg S2-S1
        Order_Std =RegClickGen(ICI2, S1Dur(dIndex), Amp, "fs", fs);
        Order_Dev =RegClickGen(ICI1, S2Dur, Amp, "fs", fs);
        for iIndex = 1 : length(Order_Dev)
            sounds(dIndex).Wave(iIndex+length(Order_Std)) = merge_S1S2("Seq_Tag", "S2_S1", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Reg");
        end
    end
    
    temp = sounds(dIndex).Wave;
    mkdir(rootPath);
    for sIndex = 1 : length(temp)
        soundName = strcat(rootPath, "\", temp(sIndex).Name, "_", sounds(dIndex).Info, ".wav");
        audiowrite(soundName, temp(sIndex).Wave, fs);
    end

end
if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end
end