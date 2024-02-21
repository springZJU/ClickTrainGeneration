function TBOffsetParams = ParseThreeScales_Params(xlsxPath, ID)
narginchk(1, 2);
if nargin < 2
    ID = 101;
end

% load excel
[~, opts] = getTableValType(xlsxPath, "0");
configTable = table2struct(readtable(xlsxPath, opts));
mProtocol = configTable(ismember([configTable.ID]', ID));

% general settings
TBOffsetParams.fs = mProtocol.fs;
TBOffsetParams.Info = mProtocol.Info;
TBOffsetParams.folderName = mProtocol.folderName;
TBOffsetParams.ParentFolderName = mProtocol.ParentFolderName;
if ~isnan(str2double(mProtocol.clickDur))
    TBOffsetParams.clickDur = str2double(mProtocol.clickDur);
else
    eval(strcat("temp = ", mProtocol.clickDur));
    TBOffsetParams.clickDur = temp;
end

TBOffsetParams.Amp = mProtocol.Amp;


% For Temporal Bindings
TBOffsetParams.S1Dur = str2double(strsplit(mProtocol.S1Dur, ","))';
TBOffsetParams.S2Dur = str2double(strsplit(mProtocol.S2Dur, ","))';
TBOffsetParams.ICIBase = str2double(strsplit(mProtocol.ICIBase, ","))';
TBOffsetParams.ratio = str2double(strsplit(mProtocol.ratio, ","))';

sigma =  string(strsplit(mProtocol.sigma, ";"));
for cIndex = 1 : length(sigma) 
    TBOffsetParams.sigma{cIndex, 1} = str2double(strsplit(sigma(cIndex), ","));
end
TBOffsetParams.ICIRangeRatio = str2double(strsplit(mProtocol.ICIRangeRatio, ","));
TBOffsetParams.repNs = str2double(strsplit(mProtocol.repNs, ","));
TBOffsetParams.repHead = mProtocol.repHead;
TBOffsetParams.repTail = mProtocol.repTail;
TBOffsetParams.repRatio = str2double(strsplit(mProtocol.repRatio, ","));

TBOffsetParams.change_TimePoint = str2double(strsplit(mProtocol.change_TimePoint, ","));

% For Tone/Complex Tone Generation
TBOffsetParams.cutLength = mProtocol.cutLength; 
TBOffsetParams.f1 = str2double(strsplit(mProtocol.f1, ","));
TBOffsetParams.f2 = str2double(strsplit(mProtocol.f2, ","));
TBOffsetParams.SuccessiveDuration = mProtocol.SuccessiveDuration;
TBOffsetParams.order = mProtocol.order;
TBOffsetParams.BFScale = str2double(strsplit(mProtocol.BFScale, ","));
TBOffsetParams.BFNum = mProtocol.BFNum;
TBOffsetParams.toneRiseFall = mProtocol.toneRiseFall;
TBOffsetParams.clickType = mProtocol.clickType;


% For Offset
TBOffsetParams.changeICI_Tail_N = str2double(strsplit(mProtocol.changeICI_Tail_N, ","));
TBOffsetParams.changeICI_Head_N = str2double(strsplit(mProtocol.changeICI_Head_N, ","));
TBOffsetParams.lastClick = mProtocol.lastClick;
localChange =  string(strsplit(mProtocol.localChange, ";"));
for cIndex = 1 : length(localChange) 
    TBOffsetParams.localChange{cIndex, 1} = str2double(strsplit(localChange(cIndex), ","));
end

% For Jitter
Jitter =  string(strsplit(mProtocol.Jitter, ";"));
for cIndex = 1 : length(Jitter) 
    TBOffsetParams.Jitter{cIndex, 1} = str2double(strsplit(Jitter(cIndex), ","));
end
TBOffsetParams.JitterMethod = mProtocol.JitterMethod;

repRatioHead =  string(strsplit(mProtocol.repRatioHead, ";"));
for cIndex = 1 : length(repRatioHead) 
    TBOffsetParams.repRatioHead{cIndex, 1} = str2double(strsplit(repRatioHead(cIndex), ","));
end
TBOffsetParams.repRatioTail = str2double(strsplit(mProtocol.repRatioTail, ","));

% For skewness
TBOffsetParams.skewBase = str2double(strsplit(mProtocol.skewBase, ","));
TBOffsetParams.skewType = mProtocol.skewType;

% Others
TBOffsetParams.soundType = mProtocol.soundType;
eval(strcat("TBOffsetParams.GenFcn = ", string(mProtocol.GenFcn), ";"));
TBOffsetParams.saveMat = logical(mProtocol.saveMat);
TBOffsetParams.loadFileName = mProtocol.loadFileName;
end
