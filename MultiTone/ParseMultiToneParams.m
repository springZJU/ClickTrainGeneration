function MultiToneParams = ParseMultiToneParams(xlsxPath, id)
narginchk(1, 2);
if nargin < 2
    id = 1;
end

% load excel
configTable = table2struct(readtable(xlsxPath));
mProtocol = configTable(id);

% parse MultiToneParams
MultiToneParams.fs = mProtocol.fs;
MultiToneParams.freqStart = mProtocol.freqStart;
MultiToneParams.freqEnd = mProtocol.freqEnd;
MultiToneParams.freqN = mProtocol.freqN;
MultiToneParams.singleDur = mProtocol.singleDur;
MultiToneParams.riseFallTime = mProtocol.riseFallTime;
MultiToneParams.overlap = str2double(string(strsplit(mProtocol.overlap, ",")));

end

