function res = merge_MMN_Sequence(varargin)
mIp = inputParser;
mIp.addParameter("Seq_Tag", [], @(x) validatestruct(x, any({'S1_S2', 'S2_S1', 'ManyStd_S2', 'ManyStd_S1'})));
mIp.addParameter("BG_Start", [], @(x) isstruct(x));
mIp.addParameter("BG_Epoc", [], @(x) isstruct(x));
mIp.addParameter("Std_Wave", [], @(x) isstruct(x));
mIp.addParameter("Dev_Wave", [], @(x) isstruct(x));
mIp.parse(varargin{:});

Seq_Tag = mIp.Results.Seq_Tag;
BG_Start = mIp.Results.BG_Start;
BG_Epoc = mIp.Results.BG_Epoc;
Std_Wave = mIp.Results.Std_Wave;
Dev_Wave = mIp.Results.Dev_Wave;


if isempty(Seq_Tag)
    error("Sequence Tag is missing!!!");
end
if isempty(BG_Start)
   BG_Start.Duration = 0;
   BG_Start.Wave = [];
end
if isempty(BG_Epoc)
    error("Back ground during MMN sequence is missing!!!");
end
if isempty(Std_Wave)
    error("Std Wave is missing!!!");
end
if isempty(Dev_Wave)
    error("Dev Wave is missing!!!");
end

res.Tag = Seq_Tag;
res.Wave = [BG_Start.Wave; ...
    cell2mat(reshape([{Std_Wave.Wave}; {BG_Epoc.Wave}], [], 1)); ...
    Dev_Wave.Wave;...
    BG_Start.Wave];
res.ICISeq = [vertcat(Std_Wave.ICIs); Dev_Wave.ICIs]; 
res.BG_Offset = BG_Start.Duration;
res.Std_Dev_Onset = res.BG_Offset + 1/BG_Epoc(1).fs +  [0; cumsum(vertcat(Std_Wave.Duration) + vertcat(BG_Epoc.Duration))];
res.Seq_Offset = res.Std_Dev_Onset(end) + Dev_Wave.LastClickOnset;
res.Onset_Index = [1; find(diff(res.Wave) > 0)];
res.Interval = diff(res.Onset_Index);
res.fs = BG_Epoc.fs;
if length(unique(vertcat(Std_Wave.ICIs))) == 1
    res.Name = strcat("MMN_Seq_Std-", strrep(num2str(Std_Wave(1).ICIs), ".", "o"), "_Dev-", strrep(num2str(Dev_Wave.ICIs), ".", "o"),...
       "_ISI-", num2str(round(Std_Wave(1).Duration + BG_Epoc(1).Duration)), "ms_StdDur-", num2str(round(Std_Wave(1).Duration))...
        , "ms_BGICI-",num2str(round(BG_Epoc(1).ICIs)), ...
        "ms_StdNum-", num2str(length(Std_Wave)), "_BG_Start-", num2str(round(BG_Start.Duration)), ".wav");
else
    res.Name = strcat("MMN_Seq_ManyStd_Dev-", strrep(num2str(Dev_Wave.ICIs), ".", "o"),...
        "_ISI-", num2str(round(Std_Wave(1).Duration + BG_Epoc(1).Duration)), "ms_StdDur-", num2str(round(Std_Wave(1).Duration))...
        , "ms_BGICI-",num2str(round(BG_Epoc(1).ICIs)), ...
        "ms_StdNum-", num2str(length(Std_Wave)), "_BG_Start-", num2str(round(BG_Start.Duration)), ".wav");
end


