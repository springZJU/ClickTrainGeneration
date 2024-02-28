function res = merge_MSTIomi_Sequence(varargin)
mIp = inputParser;

mIp.addParameter("Seq_Tag", [], @(x) any(validatestring(x, {'S1_S2', 'S2_S1', 'ManyStd_S12', 'ManyStd_S21'})));
mIp.addParameter("BG_Start", [], @(x) isstruct(x));
mIp.addParameter("BG_End", [], @(x) isstruct(x));
mIp.addParameter("S1_Wave", [], @(x) isstruct(x));
mIp.addParameter("S2_Wave", [], @(x) isstruct(x));
mIp.addParameter("fs", [], @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.parse(varargin{:});

Seq_Tag = mIp.Results.Seq_Tag;
BG_Start = mIp.Results.BG_Start;
BG_End = mIp.Results.BG_End;
S1_Wave = mIp.Results.S1_Wave;
S2_Wave = mIp.Results.S2_Wave;
fs = mIp.Results.fs;

if isempty(Seq_Tag)
    error("Sequence Tag is missing!!!");
end
if isempty(BG_Start)
   BG_Start.Duration = 0;
   BG_Start.Wave = [];
end
if isempty(BG_End)
   BG_End.Duration = 0;
   BG_End.Wave = [];
end

if isempty(S1_Wave)
    error("S1 Wave is missing!!!");
end
if isempty(S2_Wave)
    error("S2 Wave is missing!!!");
end

if length(unique(vertcat(S1_Wave.ICIs))) == 1
    clear S1S2temp S1 S2
    S1S2temp = reshape([S1_Wave;S2_Wave],[],1);
    S1 = S1S2temp(1:numel(S1_Wave));
    S2 = S1S2temp((end - numel(S2_Wave)+1):end);
    S1S2temp(1:2:end) = S1;
    S1S2temp(2:2:end) = S2;
else
    S1S2temp = reshape([S1_Wave;S2_Wave],[],1);
end

Wholetemp = [S1S2temp;BG_End];
Onsettemp = 1/fs +  [0; cumsum(vertcat(Wholetemp.Duration))];

res.Tag = Seq_Tag;
res.Wave = cell2mat({Wholetemp.Wave}');
res.ICISeq = vertcat(Wholetemp(1:end-1).ICIs);
res.S1_S2_Onset = Onsettemp(1:end);
if length(unique(vertcat(S1_Wave.ICIs))) == 1
    res.BG_End_Onset = Onsettemp(end - 1) + S1_Wave(1).LastClickOnset + 1/fs;
    res.Omission_Point = res.BG_End_Onset + S1_Wave(1).Duration; 
else
    res.BG_End_Onset = Onsettemp(end - 1) + S2_Wave(1).LastClickOnset + 1/fs;
    res.Omission_Point = res.BG_End_Onset + S2_Wave(1).Duration; 
end

res.Onset_Index = find(diff([0; res.Wave]) > 0);
res.Interval = diff(res.Onset_Index);
res.fs = fs;
res.SeqOffset = sum(res.Interval) / res.fs;
if length(unique(vertcat(S1_Wave.ICIs))) == 1
    res.Name = strcat("MMN_Seq_S1-", strrep(num2str(S1_Wave(1).ICIs), ".", "o"),...
       "_S2-", strrep(num2str(S2_Wave(1).ICIs), ".", "o"),...
       "_ISI-", num2str(round(S1_Wave(1).Duration + S2_Wave(1).Duration)),...
       "ms_S1Dur-", num2str(round(S1_Wave(1).Duration)),...
       "ms_S2Dur-", num2str(round(S2_Wave(1).Duration)),...
       "ms_BGICI-",num2str(round(BG_End(1).ICIs)),...
       "ms_StdNum-", num2str(length(S1_Wave)), ".wav");
else
    res.Name = strcat("MMN_Seq_ManyStd_S1-", strrep(num2str(S2_Wave(1).ICIs), ".", "o"),...
        "_S2-", strrep(num2str(S2_Wave(2).ICIs), ".", "o"),...
        "_ISI-", num2str(round(S1_Wave(1).Duration + S2_Wave(1).Duration)),...
        "ms_S1Dur-", num2str(round(S1_Wave(1).Duration)),...
        "ms_S2Dur-", num2str(round(S2_Wave(1).Duration)),...
        "ms_BGICI-",num2str(round(BG_End(1).ICIs)), ...
        "ms_StdNum-", num2str(length(S1_Wave)), ".wav");
end


