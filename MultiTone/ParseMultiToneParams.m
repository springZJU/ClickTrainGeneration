function MultiToneParams = ParseMultiToneParams(xlsxPath, ID)
narginchk(1, 2);
if nargin < 2
    ID = 1;
end

% load excel
[~, opts] = getTableValType(xlsxPath, "0");
configTable = table2struct(readtable(xlsxPath, opts));
mProtocol = configTable(ismember([configTable.ID]', ID));

% folder information
MultiToneParams.ParentFolderName = mProtocol.ParentFolderName;
MultiToneParams.folderName = mProtocol.folderName;

% parse MultiToneParams
MultiToneParams.ID = mProtocol.ID;
MultiToneParams.fs = mProtocol.fs;
MultiToneParams.freqStart = mProtocol.freqStart;
MultiToneParams.freqEnd = mProtocol.freqEnd;
MultiToneParams.freqN = mProtocol.freqN;
MultiToneParams.singleDur = mProtocol.singleDur;
MultiToneParams.riseFallTime = mProtocol.riseFallTime;
MultiToneParams.overlap = str2double(string(strsplit(mProtocol.overlap, ",")));

% local change
MultiToneParams.LocalChange = mProtocol.LocalChange;
MultiToneParams.FreqDiff = str2double(string(strsplit(mProtocol.FreqDiff, ",")))';
MultiToneParams.AmpDiff = str2double(string(strsplit(mProtocol.AmpDiff, ",")))';
MultiToneParams.ChangePoint = mProtocol.ChangePoint;
MultiToneParams.ChangeDuration = mProtocol.ChangeDuration;



eval(strcat("MultiToneParams.GenFcn = ", string(mProtocol.GenFcn), ";"));

end

