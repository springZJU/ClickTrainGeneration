function TBOffsetParams = ParseTB_Offset_Params(xlsxPath, ID)
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
TBOffsetParams.Amp = mProtocol.Amp;


% For Temporal Bindings
TBOffsetParams.S1Dur = str2double(strsplit(mProtocol.S1Dur, ","))';
TBOffsetParams.S2Dur = str2double(strsplit(mProtocol.S2Dur, ","))';
TBOffsetParams.ICIBase = str2double(strsplit(mProtocol.ICIBase, ","))';
TBOffsetParams.ratio = str2double(strsplit(mProtocol.ratio, ","))';

TBOffsetParams.sigma = str2double(strsplit(mProtocol.sigma, ","))';
TBOffsetParams.repNs = str2double(strsplit(mProtocol.repNs, ","));
TBOffsetParams.repHead = mProtocol.repHead;
TBOffsetParams.repTail = mProtocol.repTail;
TBOffsetParams.repRatio = str2double(strsplit(mProtocol.repRatio, ","));

% For Tone Generation
TBOffsetParams.cutLength = mProtocol.cutLength; 
TBOffsetParams.f1 = str2double(strsplit(mProtocol.f1, ","));
TBOffsetParams.f2 = str2double(strsplit(mProtocol.f2, ","));
TBOffsetParams.SuccessiveDuration = mProtocol.SuccessiveDuration;
TBOffsetParams.BFScale = str2double(strsplit(mProtocol.BFScale, ","));
TBOffsetParams.BFNum = mProtocol.BFNum;

% Others
TBOffsetParams.soundType = mProtocol.soundType;
eval(strcat("TBOffsetParams.GenFcn = ", string(mProtocol.GenFcn), ";"));
TBOffsetParams.saveMat = logical(mProtocol.saveMat);
TBOffsetParams.loadFileName = mProtocol.loadFileName;
end

