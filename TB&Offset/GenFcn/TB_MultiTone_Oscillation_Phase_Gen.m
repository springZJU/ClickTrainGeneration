function TB_MultiTone_Oscillation_Phase_Gen(TBOffsetParams)


parseStruct(TBOffsetParams);
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
mkdir(rootPath);

for index = 1 : length(S1Dur)
    riseFallTime = 5; % ms
    toneLength = S1Dur(index);
    % merge tone
    orders = num2cell(1:order);
    wave1 = cellfun(@(x) joinTone(f1*2^(x-1), f2*2^(x-1), toneLength, SuccessiveDuration, fs), orders, "UniformOutput", false);
    wave1 = mean(cell2mat(wave1'), 1);
    wave1 = Amp/order * wave1;

    t = 1/fs : 1 /fs : length(wave1)/fs;
    % calculate rise fall index
    tR = find(t*1000 < riseFallTime);
    tF = find(t*1000 > (SuccessiveDuration - riseFallTime));
    riseFallR = length(tR);
    riseFallN = length(tF);
    if riseFallTime
        tR(end) = [];
        tF(1) = [];
    end
    sigRise = 1*((sin(pi*(0:1/(riseFallR-1):(1 - 1/(riseFallR-1)))-0.5*pi)+1)/2);
    sigFall = 1*((sin(pi*(0:1/(riseFallN-1):(1 - 1/(riseFallN-1)))+0.5*pi)+1)/2);

    wave1(tR) = wave1(tR) .* sigRise;
    wave1(tF) = wave1(tF) .* sigFall;
    wave1Str = strcat(num2str(fix(f1)), "_Dur", num2str(S1Dur(index)), "_Successive_MultiTone.wav");
    % save sound
    audiowrite(fullfile(rootPath,  strcat(num2str(toneLength), "ms_", wave1Str)), wave1, fs);
end
