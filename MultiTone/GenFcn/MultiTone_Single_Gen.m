function multiTone = MultiTone_Single_Gen(MultiToneParams)
parseStruct(MultiToneParams);

%% generate sounds
freqPool = round(logspace(log10(freqStart), log10(freqEnd), freqN))';

A = 1/freqN/2;
T = 0 : 1/fs : singleDur/1000;
riseFallEnvelope = RiseFallEnve(singleDur, riseFallTime, fs);
riseFallEnvelope = [riseFallEnvelope, zeros(1, length(T)-length(riseFallEnvelope))];
if LocalChange
    changeIdx = find(T >= ChangePoint/1000 & T <= ChangePoint/1000 + ChangeDuration/1000);
    segSamples   = [changeIdx(1)-1, length(changeIdx), length(T)-changeIdx(end)];
    if ~isequal(FreqDiff, 0)
        tempSound = cellfun(@(x) sum(cell2mat(cellfun(@(y) A*joinToneSeq([1, 1+x, 1]*y, segSamples, fs), num2cell(freqPool), "uni", false))), num2cell(FreqDiff), "uni", false);
        if length(AmpDiff) == length(FreqDiff)
            tempSound = cellfun(@(x) [ones(1, segDurs(1)), (1+x)*A*ones(1, segDurs(2)), ones(1, segDurs(3))].*tempSound, num2cell(AmpDiff), "UniformOutput", false);
            Info = cellfun(@(x, y) strcat("ComplexTone_Dur-", num2str(singleDur), "ms_LocalChange-", num2str(ChangePoint), "ms_Dur-", num2str(ChangeDuration), "ms_Freq-", num2str(x), "ms_Amp-", num2str(y), "_Freqs-", strjoin(string([freqPool(1), freqPool(end)]), "-"), "-N", num2str(length(freqPool))), num2cell(FreqDiff), num2cell(AmpDiff), "UniformOutput", false);
        elseif ~isequal(AmpDiff, 0)
            Info = cellfun(@(x) strcat("ComplexTone_Dur-", num2str(singleDur), "ms_LocalChange-", num2str(ChangePoint), "ms_Dur-", num2str(ChangeDuration), "ms_Freq-", num2str(x), "_Freqs-", strjoin(string([freqPool(1), freqPool(end)]), "-"), "-N", num2str(length(freqPool))), num2cell(FreqDiff), "UniformOutput", false);
            warning("AmpDiff and FreqDiff should have same length")
        else
            Info = cellfun(@(x) strcat("ComplexTone_Dur-", num2str(singleDur), "ms_LocalChange-", num2str(ChangePoint), "ms_Dur-", num2str(ChangeDuration), "ms_Freq-", num2str(x), "_Freqs-", strjoin(string([freqPool(1), freqPool(end)]), "-"), "-N", num2str(length(freqPool))), num2cell(FreqDiff), "UniformOutput", false);
        end
            tempSound = cellfun(@(x) riseFallEnvelope.*x, tempSound, "UniformOutput", false);
            tempFreq = repmat({freqPool}, length(FreqDiff), 1);
    elseif ~isequal(AmpDiff, 0)
        pieces = cellfun(@(x) A*cos(2*pi*x*T), num2cell(freqPool), "uni", false);
        tempSound = cellfun(@(x) riseFallEnvelope.*[ones(1, segSamples(1)), (1+x)*ones(1, segSamples(2)), ones(1, segSamples(3))].*sum(cell2mat(pieces)), num2cell(AmpDiff), "UniformOutput", false);
        tempFreq = repmat({freqPool}, length(AmpDiff), 1);
        Info = cellfun(@(x) strcat("ComplexTone_Dur-", num2str(singleDur), "ms_LocalChange-", num2str(ChangePoint), "ms_Dur-", num2str(ChangeDuration), "ms_Amp-", num2str(x), "_Freqs-", strjoin(string([freqPool(1), freqPool(end)]), "-"), "-N", num2str(length(freqPool))), num2cell(AmpDiff), "UniformOutput", false);
    end
else
    pieces = cellfun(@(x) A*cos(2*pi*x*T), num2cell(freqPool), "uni", false);
    pieces = cellfun(@(x) riseFallEnvelope.*x, pieces, "UniformOutput", false)';
    tempSound{1, 1} = sum(cell2mat(pieces));
    tempFreq{1,1} = freqPool;
    Info = strcat("ComplexTone_Dur-", num2str(singleDur), "ms_Freqs-", strjoin(num2str([freqPool(1), freqPool(end)]), "-"), "-N", num2str(length(freqPool)));
end



%% Package sounds
multiTone = cell2struct([cellstr(Info), tempSound, num2cell(repmat(singleDur,length(tempSound),1)), tempFreq], ["Info", "Sound", "Dur", "Freq"], 2);

%% save folder
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
mkdir(rootPath);


%% export
for sIndex = 1 : length(multiTone)
    soundName = strcat(rootPath, "\", multiTone(sIndex).Info, ".wav");
    audiowrite(soundName, multiTone(sIndex).Sound, fs);
end

save(fullfile(rootPath, "multiTone.mat"), "multiTone");