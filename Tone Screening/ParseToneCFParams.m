function ToneCFParams = ParseToneCFParams(xlsxPath, ID)
narginchk(1, 2);
if nargin < 2
    ID = 1;
end

% load excel
[~, opts] = getTableValType(xlsxPath, "0");
configTable = table2struct(readtable(xlsxPath, opts));
mProtocol = configTable(ismember([configTable.ID]', ID));

% general settings
ToneCFParams.ID = mProtocol.ID;
ToneCFParams.fs = mProtocol.fs;
ToneCFParams.Amp = mProtocol.Amp;
ToneCFParams.folderName = mProtocol.folderName;
ToneCFParams.ParentFolderName = mProtocol.ParentFolderName;

% For Tone CF
ToneCFParams.freqStart = mProtocol.freqStart;
ToneCFParams.freqEnd = mProtocol.freqEnd;
ToneCFParams.freqN = mProtocol.freqN;
ToneCFParams.singleDur = str2double(strsplit(mProtocol.singleDur, ","));
ToneCFParams.riseFallTime = mProtocol.riseFallTime;
ToneCFParams.Attenuation = str2double(strsplit(mProtocol.Attenuation, ","));
eval(strcat("ToneCFParams.GenFcn = ", string(mProtocol.GenFcn), ";"));
end

