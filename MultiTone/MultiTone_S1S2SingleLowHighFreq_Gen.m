function multiTone = MultiTone_S1S2SingleOddEven_Gen(MultiToneParams)
parseStruct(MultiToneParams);

%% generate sounds
freqPool = round(logspace(log10(freqStart), log10(freqEnd), freqN));

A = 1/freqN;
T = 1/fs : 1/fs : singleDur/1000;
riseFallEnvelope = RiseFallEnve(singleDur, riseFallTime, fs);
pieces = cellfun(@(x) A*cos(2*pi*x*T), num2cell(freqPool), "uni", false);
pieces = cellfun(@(x) riseFallEnvelope.*x, pieces, "UniformOutput", false)';
S1 = sum(cell2mat(pieces(1:floor(length(pieces)/2))));
S1Freq = freqPool(1:floor(length(pieces)/2));
S2 = sum(cell2mat(pieces(floor(length(pieces)/2)+1:end)));
S2Freq = freqPool(floor(length(pieces)/2)+1:end);
    
tempS1 = zeros(1, length(S1));
tempS1(1, 1:length(S1)) = S1;

tempS2 = zeros(1, length(S2));
tempS2(1, 1:length(S2)) = S2;

tempSound{1,1} = tempS1;
tempSound{2,1} = tempS2;
tempFreq{1,1} = S1Freq;
tempFreq{2,1} = S2Freq;

Info(1, 1) = strcat("SingleDur-", num2str(singleDur), "ms_SingleS1LowFreq", "_FreqN-", num2str(freqN));
Info(2, 1) = strcat("SingleDur-", num2str(singleDur), "ms_SingleS2HighFreq", "_FreqN-", num2str(freqN));
%% Package sounds
multiTone = easyStruct(["Info", "SingleSound", "singleDur", "Freq"], ...
    [cellstr(Info), tempSound, num2cell(repmat(singleDur,2,1)), tempFreq]);


%% save folder
folderName = strcat("MultiTone_ID", num2str(ID));
rootPath = fullfile('..\..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
mkdir(rootPath);


%% export
for sIndex = 1 : length(multiTone)
    soundName = strcat(rootPath, "\", multiTone(sIndex).Info, ".wav");
    audiowrite(soundName, multiTone(sIndex).SingleSound, fs);
end

save(fullfile(rootPath, "multiTone.mat"), "multiTone");