function ToneCF = ToneLocalChange(ToneCF, fs, LocalPos, LocalDur, LocalRatio)
    fd = fs*LocalRatio; % resample fs
    T = (1/fs: 1/fs : length(ToneCF)/fs)'*1000;
    
    [~, ~, idxNP] = findZeroPoint(ToneCF);
    [~, minIdx1] = min(abs((idxNP- LocalPos/1000*fs)));
    [~, minIdx2] = min(abs((idxNP- (LocalPos+LocalDur)/1000*fs)));
    idealPos = idxNP([minIdx1, minIdx2]);
    ToneSeg{1,1} = ToneCF(1:idealPos(1)-1);
    ToneSeg{1,2} = ToneCF(idealPos(1):idealPos(2));
    ToneSeg{1,3} = ToneCF(idealPos(2)+1:end);
    ToneSeg{1,2} = cell2mat(ECOGResample(ToneSeg(2), fd, fs));
    ToneCF = cell2mat(ToneSeg);
end