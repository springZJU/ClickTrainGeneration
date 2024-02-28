function sounds = TB_Jitter_Gen(TBOffsetParams)
parseStruct(TBOffsetParams);
for jIndex = 1 : length(Jitter)
    clearvars -except TBOffsetParams rIndex repNs sounds irregICISampNBase Jitter jIndex

    parseStruct(TBOffsetParams);
    rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
    jitterTemp = Jitter{jIndex};
    sounds(jIndex).Info = strcat("Jitter", string(Jitter{jIndex}(1)), "-", string(Jitter{jIndex}(2)));

    %% Generate Click Trains
    ICI1 = repmat(ICIBase, length(ratio), 1);
    ICI2 = ICI1.*repmat(ratio, length(ICIBase), 1);
    [~, idx] = sortrows([ICI1, ICI2], [1, 2]);
    ICI1 = ICI1(idx); ICI2 = ICI2(idx);
    if contains(soundType, ["Reg&Irreg", "Irreg"]) % for regualr
        % generate Jitter S1-S2
        Order_Std =JitterClickGen(ICI1, S1Dur, Amp,  "repTail", repTail*repRatioTail, "fs", fs, "Jitter", jitterTemp, "JitterMethod", "EvenOdd", "clickType", clickType);
        Order_Dev =JitterClickGen(ICI2, S2Dur, Amp, "fs", fs, "Jitter", jitterTemp, "JitterMethod", "EvenOdd", "lastClick", lastClick , "clickType", clickType);
        for rIndex = 1 : length(repRatioHead)
            Order_Dev =ClickTrainRep(Order_Dev, Amp, "repHead", repHead*repRatioHead{rIndex}, "repTail", repTail*repRatioHead{rIndex}, "fs", fs);
            for iIndex = 1 : length(Order_Std)
                sounds(jIndex).Wave((rIndex-1)*length(Order_Std) + iIndex) = merge_S1S2("Seq_Tag", strcat("S1_S2_", strjoin(string(repTail*repRatioHead{rIndex}), "-")), "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Reg");
            end
        end
        % generate Jitter S2-S1
        Order_Std =JitterClickGen(ICI2, S1Dur, Amp,  "repTail", repTail*repRatioTail, "fs", fs, "Jitter", jitterTemp, "JitterMethod", "EvenOdd", "clickType", clickType);
        Order_Dev =JitterClickGen(ICI1, S2Dur, Amp, "fs", fs, "Jitter", jitterTemp, "JitterMethod", "EvenOdd", "lastClick", lastClick , "clickType", clickType);
        for rIndex = 1 : length(repRatioHead)
            Order_Dev =ClickTrainRep(Order_Dev, Amp, "repHead", repHead*repRatioHead{rIndex}, "repTail", repTail*repRatioHead{rIndex}, "fs", fs);
            for iIndex = 1 : length(Order_Std)
                sounds(jIndex).Wave((length(repRatioHead)+rIndex-1)*length(Order_Std) + iIndex) = merge_S1S2("Seq_Tag", strcat("S2_S1_", strjoin(string(repTail*repRatioHead{rIndex}), "-")), "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Reg");
            end
        end
    end
end

mkdir(rootPath);
for jIndex = 1 : length(sounds)
    temp = sounds(jIndex).Wave;
    for sIndex = 1 : length(temp)
        soundName = strcat(rootPath, "\", temp(sIndex).Name, "_", temp(sIndex).Tag, sounds(jIndex).Info, ".wav");
        audiowrite(soundName, temp(sIndex).Wave, fs);
    end
end


if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end
end