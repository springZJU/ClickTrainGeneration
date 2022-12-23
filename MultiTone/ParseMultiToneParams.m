function MultiToneParams = ParseMultiToneParams(xlsxPath, ID)
narginchk(1, 2);
if nargin < 2
    ID = 1;
end

% load excel
configTable = table2struct(readtable(xlsxPath));
mProtocol = configTable(ismember([configTable.ID]', ID));

% parse MultiToneParams
MultiToneParams.ID = mProtocol.ID;
MultiToneParams.fs = mProtocol.fs;
MultiToneParams.freqStart = mProtocol.freqStart;
MultiToneParams.freqEnd = mProtocol.freqEnd;
MultiToneParams.freqN = mProtocol.freqN;
MultiToneParams.singleDur = mProtocol.singleDur;
MultiToneParams.riseFallTime = mProtocol.riseFallTime;
MultiToneParams.overlap = str2double(string(strsplit(mProtocol.overlap, ",")));
eval(strcat("MultiToneParams.GenFcn = ", string(mProtocol.GenFcn), ";"));

end

