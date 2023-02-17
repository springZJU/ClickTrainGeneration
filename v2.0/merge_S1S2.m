function res = merge_S1S2(varargin)
mIp = inputParser;
mIp.addParameter("Seq_Tag", [], @(x) validatestruct(x, any({'S1_S2', 'S2_S1'})));
mIp.addParameter("Std_Wave", [], @(x) isstruct(x));
mIp.addParameter("Dev_Wave", [], @(x) isstruct(x));
mIp.addParameter("soundType", [], @(x) validatestruct(x, any({'Reg', 'Irreg', 'IFFT'})));

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
res.Name = strcat("TB_", soundType, "_", strrep(num2str(Std_Wave(1).ICIs), ".", "o"), "-", strrep(num2str(Dev_Wave.ICIs), ".", "o"));
res.Wave = [Std_Wave.Wave; Dev_Wave.Wave];
res.ICISeq = [Std_Wave.ICIs; Dev_Wave.ICIs];
res.Std_Dev_Onset = [0; Std_Wave.Duration];
res.Onset_Index = find(diff([0; res.Wave]) > 0);
res.Interval = diff(res.Onset_Index);
res.fs = Std_Wave.fs;
res.SeqOffset = sum(res.Interval) / res.fs;
res.StdWave = Std_Wave;
res.DevWave = Dev_Wave;

end


