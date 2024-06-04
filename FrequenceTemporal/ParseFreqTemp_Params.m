function FreqTempParams = ParseFreqTemp_Params(xlsxPath, ID)
narginchk(1, 2);
if nargin < 2
    ID = 1;
end

% load excel
[~, opts] = getTableValType(xlsxPath, "0");
configTable = table2struct(readtable(xlsxPath, opts));
mProtocol = configTable(ismember([configTable.ID]', ID));

% general settings
FreqTempParams.fs = mProtocol.fs;
FreqTempParams.Info = mProtocol.Info;
FreqTempParams.folderName = mProtocol.folderName;
FreqTempParams.ParentFolderName = mProtocol.ParentFolderName;
FreqTempParams.Amp = mProtocol.Amp;

% For sequence
FreqTempParams.ISI = str2double(strsplit(mProtocol.ISI, ","))';
FreqTempParams.clickDur = mProtocol.clickDur;
FreqTempParams.toneRiseFall = mProtocol.toneRiseFall;
FreqTempParams.RepNum = mProtocol.RepNum;
FreqTempParams.stdNum = mProtocol.stdNum;

% For FreqTemp feature
FreqTempParams.TrainDur = mProtocol.TrainDur;
% frequence feature
FreqTempParams.FreqRange = str2double(strsplit(mProtocol.FreqRange, ","))';
FreqTempParams.FreqDevratio = mProtocol.FreqDevratio;
FreqTempParams.Freq_Apply = mProtocol.Freq_Apply;
% temporal feature
FreqTempParams.ITI = mProtocol.ITI;
FreqTempParams.ITIDevratio = mProtocol.ITIDevratio;

% Others
FreqTempParams.clickType = mProtocol.clickType;
FreqTempParams.soundType = mProtocol.soundType;
eval(strcat("FreqTempParams.GenFcn = ", string(mProtocol.GenFcn), ";"));
FreqTempParams.saveMat = logical(mProtocol.saveMat);
end

