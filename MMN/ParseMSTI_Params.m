function MSTIParams = ParseMSTI_Params(xlsxPath, ID)
narginchk(1, 2);
if nargin < 2
    ID = 1;
end

% load excel
[~, opts] = getTableValType(xlsxPath, "0");
configTable = table2struct(readtable(xlsxPath, opts));
mProtocol = configTable(ismember([configTable.ID]', ID));

% general settings
MSTIParams.fs = mProtocol.fs;
MSTIParams.Info = mProtocol.Info;
MSTIParams.folderName = mProtocol.folderName;
MSTIParams.ParentFolderName = mProtocol.ParentFolderName;
MSTIParams.Amp = mProtocol.Amp;

% For external sound selection
MSTIParams.SoundPath = mProtocol.SoundPath;
MSTIParams.SoundSelect = strsplit(mProtocol.SoundSelect, ",");
MSTIParams.SoundRand = strsplit(mProtocol.SoundRand, ",");

% For MSTI
MSTIParams.ISI = str2double(strsplit(mProtocol.ISI, ","))';
MSTIParams.BG_Start_Dur = mProtocol.BG_Start_Dur;
MSTIParams.BG_End_Dur = mProtocol.BG_End_Dur;
MSTIParams.stdDur = str2double(strsplit(mProtocol.stdDur, ","))';
MSTIParams.devDur = str2double(strsplit(mProtocol.devDur, ","))';
MSTIParams.stdNum = mProtocol.stdNum;

% For Temporal Bindings
MSTIParams.ISI = str2double(strsplit(mProtocol.ISI, ","))';
MSTIParams.BG_Start_Dur = mProtocol.BG_Start_Dur;
MSTIParams.BG_End_Dur = mProtocol.BG_End_Dur;
MSTIParams.stdDur = str2double(strsplit(mProtocol.stdDur, ","))';
MSTIParams.devDur = str2double(strsplit(mProtocol.devDur, ","))';
MSTIParams.stdNum = mProtocol.stdNum;

MSTIParams.BG_Base = mProtocol.BG_Base;
MSTIParams.S1_S2_Base = str2double(strsplit(mProtocol.S1_S2_Base, ","))';
MSTIParams.scaleFactor = mProtocol.scaleFactor;
MSTIParams.ManyStd_Range = str2double(strsplit(mProtocol.ManyStd_Range, ","))';
MSTIParams.ManyStd_Apply = mProtocol.ManyStd_Apply;
MSTIParams.ManyStd_Rand = mProtocol.ManyStd_Rand;

% Others
MSTIParams.soundType = mProtocol.soundType;
eval(strcat("MSTIParams.GenFcn = ", string(mProtocol.GenFcn), ";"));
MSTIParams.saveMat = logical(mProtocol.saveMat);
end

