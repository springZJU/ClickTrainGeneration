function sounds = TB_Basic_IFFT_Gen(TBOffsetParams)
parseStruct(TBOffsetParams);
for rIndex = 1 : length(repNs)
    clearvars -except TBOffsetParams rIndex repNs sounds irregICISampNBase

    parseStruct(TBOffsetParams);
    rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

    repN = repRatio(1 : repNs(rIndex));
    if ~isempty(repN)
        sounds(rIndex).Info = strcat("repN", string(repNs(rIndex)), "-", strjoin(string(repN), "_"));
    else
        sounds(rIndex).Info = strcat("No-Rep");
    end

    %% Generate Click Trains
    ICI1 = repmat(ICIBase, length(ratio), 1);
    ICI2 = ICI1.*repmat(ratio, length(ICIBase), 1);
    [~, idx] = sortrows([ICI1, ICI2], [1, 2]);
    ICI1 = ICI1(idx); ICI2 = ICI2(idx);
    if contains(soundType, ["Reg&Irreg", "Reg", "Reg&IFFT"]) % for regualr
        % generate Reg S1-S2
        Order_Std = RegClickGen(ICI1, S1Dur, Amp, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        Order_Dev = RegClickGen(ICI2, S2Dur, Amp, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);

        ifft_ICI1 = Order_Std;
        load(loadFileName);
        [res, Fig] = mIFFT(ifft_ICI1.Wave, fs, randSeq);
        ifft_ICI1.Wave = res(2).wave';
           
        ifft_ICI2 = Order_Dev;
        ifft_ICI2.Wave = resample(ifft_ICI1.Wave, round(ratio*2000), floor(1*2000));
        for iIndex = 1 : length(Order_Std)
            sounds(rIndex).Wave(iIndex) = merge_S1S2("Seq_Tag", "S1_S2", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Reg");
        end

        % generate Reg S2-S1
        Order_Std =RegClickGen(ICI2, S1Dur, Amp, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        Order_Dev =RegClickGen(ICI1, S2Dur, Amp, "repHead", repHead*repN, "repTail", repTail*repN, "fs", fs);
        for iIndex = 1 : length(Order_Dev)
            sounds(rIndex).Wave(iIndex+length(Order_Std)) = merge_S1S2("Seq_Tag", "S2_S1", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "Reg");
        end
    end


    if contains(soundType, ["Reg&Irreg", "Irreg", "Reg&IFFT"]) % for iFFT
        % generate ifft S1-S2
        Order_Std = ifft_ICI1;
        Order_Dev = ifft_ICI2;
        for iIndex = 1 : length(Order_Std)
            sounds(rIndex).Wave(iIndex+2*length(Order_Std)) = merge_S1S2("Seq_Tag", "S1_S2", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "IFFT");
        end

        % generate ifft S2-S1
        Order_Std = ifft_ICI2;
        Order_Dev = ifft_ICI1;
        for iIndex = 1 : length(Order_Dev)
            sounds(rIndex).Wave(iIndex+3*length(Order_Std)) = merge_S1S2("Seq_Tag", "S2_S1", "Std_Wave", Order_Std(iIndex), "Dev_Wave", Order_Dev(iIndex), "soundType", "IFFT");
        end
    end

    temp = sounds(rIndex).Wave;
    mkdir(rootPath);
    for sIndex = 1 : length(temp)
        soundName = strcat(rootPath, "\", temp(sIndex).Name, "_", sounds(rIndex).Info, ".wav");
        audiowrite(soundName, temp(sIndex).Wave, fs);
    end

end
mPrint(Fig, fullfile(rootPath, "soundsCompare"));
Fig.Children(1).XLim = [0, 0.1];
Fig.Children(3).XLim = [0, 0.1];
Fig.Children(2).XLim = [0, 5000];
Fig.Children(4).XLim = [0, 5000];
mPrint(Fig, fullfile(rootPath, "soundsCompare_zoomedIn"));
if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end
close(Fig);
end