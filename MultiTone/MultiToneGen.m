function multiTone = MultiToneGen(varargin)

%% To get parameters
mIp = inputParser;
mIp.addParameter("xlsxPath", ".\multiToneParameters_For_Generation.xlsx", @(x) isstring(x));
mIp.addParameter("ID", 1, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive', 'integer'}));
mIp.parse(varargin{:});

xlsxPath = mIp.Results.xlsxPath;
ID = mIp.Results.ID;

MultiToneParams = ParseMultiToneParams(xlsxPath, ID);
parseStruct(MultiToneParams);
assignin("caller", "fs", fs);

%% generate sounds
if size(overlap, 1) ~= numel(overlap)
    overlap = overlap';
end
freqPool = round(logspace(log10(freqStart), log10(freqEnd), freqN));

A = 1/freqN;
T = 1/fs : 1/fs : singleDur/1000;
riseFallEnvelope = RiseFallEnve(singleDur, riseFallTime, fs);
pieces = cellfun(@(x) A*cos(2*pi*2*T), num2cell(freqPool), "uni", false);
pieces = cellfun(@(x) riseFallEnvelope.*x, pieces, "UniformOutput", false)';
S1 = sum(cell2mat(pieces(1:2:end)));
S1Freq = freqPool(1:2:end);
S2 = sum(cell2mat(pieces(2 : 2 : end)));
S2Freq = freqPool(1:2:end);
for oIndex = 1 : length(overlap)
    OVERLAP = overlap(oIndex);

    tempS1S2 = zeros(2, length([S1, S2]) - round(OVERLAP/1000*fs));
    tempS1S2(1, 1:length(S1)) = S1;
    tempS1S2(2, end-length(S2)+1:end) = S2;
    S1S2{oIndex, 1} = sum(tempS1S2);

    tempS2S1 = zeros(2, length([S1, S2]) - round(OVERLAP/1000*fs));
    tempS2S1(1, 1:length(S2)) = S2;
    tempS2S1(2, end-length(S1)+1:end) = S1;
    S2S1{oIndex, 1} = sum(tempS2S1);

    wholeDur{oIndex, 1} = size(tempS2S1, 2)/fs*1000;
    Info(oIndex, 1) = strcat("SingleDur-", num2str(singleDur), "ms_Overlap-", ...
                                 num2str(OVERLAP), "ms_FreqN-", num2str(freqN));
end

%% Package sounds
multiTone = easyStruct(["Info", "S1S2", "S2S1", "wholeDur", "Overlap", "S1Freq", "S2Freq"], ...
           [cellstr(Info), S1S2, S2S1, wholeDur, num2cell(overlap), ...
           num2cell(repmat(S1Freq, length(overlap), 1), 2), ...
           num2cell(repmat(S2Freq, length(overlap), 1), 2), ...
           ]);
end


function parseStruct(S, sIndex)
narginchk(1, 2)
if nargin < 2
    sIndex = 1 : length(S);
end
sField = fields(S);
for fIndex = 1 : length(sField)
    % add local var to base workspace
    eval(['assignin(''caller'', ''', sField{fIndex}, ''', vertcat(S(sIndex).', sField{fIndex}, '));']);
end
end


