function res = merge_Oscillation(varargin)
mIp = inputParser;

mIp.addParameter("Seq_Tag", [], @(x) any(validatestring(x, {'S1_S2', 'S2_S1'})));
mIp.addParameter("Std_Wave", [], @(x) isstruct(x));
mIp.addParameter("Dev_Wave", [], @(x) isstruct(x));
mIp.addParameter("soundType", [], @(x) any(validatestring(x, {'Reg', 'Irreg'})));

mIp.parse(varargin{:});

Seq_Tag = mIp.Results.Seq_Tag;
Std_Wave = mIp.Results.Std_Wave;
Dev_Wave = mIp.Results.Dev_Wave;
soundType = mIp.Results.soundType;

if isempty(Seq_Tag)
    error("Sequence Tag is missing!!!");
end
if isempty(Std_Wave)
    error("Std Wave is missing!!!");
end
if isempty(Dev_Wave)
    error("Dev Wave is missing!!!");
end
if isempty(soundType)
    error("soundType is missing!!!");
end

res.Tag = strjoin([soundType ,Seq_Tag], "_");
res.Name = strcat("TB_Oscillation", soundType, "_", strrep(num2str(Std_Wave(1).ICIs), ".", "o"), "-", strrep(num2str(Dev_Wave(1).ICIs), ".", "o"));
res.Wave = cell2mat(reshape([{Std_Wave.Wave}; {Dev_Wave.Wave}], [], 1));
res.ICISeq = reshape([vertcat(Std_Wave.ICIs)'; vertcat(Dev_Wave.ICIs)'], [], 1); 
res.Std_Dev_Onset = [0; cumsum(vertcat(Std_Wave.Duration) + vertcat(Dev_Wave.Duration))];
res.Onset_Index = find(diff([0; res.Wave]) > 0);
res.Interval = diff(res.Onset_Index);
res.fs = Std_Wave.fs;
res.SeqOffset = sum(res.Interval) / res.fs;
end


