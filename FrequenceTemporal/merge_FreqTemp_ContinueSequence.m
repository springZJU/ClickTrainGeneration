function res = merge_FreqTemp_ContinueSequence(varargin)
mIp = inputParser;

mIp.addParameter("Seq_Tag", [], @(x) isstring(x));
mIp.addParameter("Std_Wave", [], @(x) isstruct(x));
mIp.addParameter("Dev_Wave", [], @(x) isstruct(x));
mIp.addParameter("clickType", [], @(x) isstring(x));
mIp.addParameter("ISI", 0, @(x) validateattributes(x, {'numeric'}, {'positive'}));
mIp.addParameter("StdNum", 0, @(x) validateattributes(x, {'numeric'}, {'positive'}));
mIp.addParameter("DevNum", 0, @(x) validateattributes(x, {'numeric'}, {'positive'}));
mIp.addParameter("RepNum", 0, @(x) validateattributes(x, {'numeric'}, {'positive'}));

mIp.parse(varargin{:});

Seq_Tag = mIp.Results.Seq_Tag;
Std_Wave = mIp.Results.Std_Wave;
Dev_Wave = mIp.Results.Dev_Wave;
clickType = mIp.Results.clickType;
ISI = mIp.Results.ISI;
StdNum = mIp.Results.StdNum;
DevNum = mIp.Results.DevNum;
RepNum = mIp.Results.RepNum;

if isempty(Seq_Tag); error("Sequence Tag is missing!!!");end
if isempty(Std_Wave); error("Std Wave is missing!!!");end
if isempty(Dev_Wave); error("Dev Wave is missing!!!");end
if isempty(StdNum); StdNum = 9;end
if isempty(DevNum); DevNum = 1;end
if isempty(RepNum); RepNum = 30;end

res.fs = Dev_Wave.fs;
res.Tag = Seq_Tag;
%%%%%%%% generate order number and sequence %%%%%%%%%
DevPosAll = []; SequenceStruct = [];
SequenceWave = cell(2, (StdNum + DevNum) * RepNum);%第一行是sound wave, 第二行是留给ISI的
if numel(Std_Wave) == 1 & numel(Dev_Wave) == 1
    % oddball
    Dev_OriginPos = 2:(StdNum + DevNum - 1);%随机化dev刺激的位置，排除dev出现在首尾的位置，避免连续的序列中dev相接
    for cycle = 1 : RepNum %产生所有dev的位置索引
        DevPosAll = [DevPosAll; (StdNum + DevNum) * (cycle - 1) + Dev_OriginPos(randperm(numel(Dev_OriginPos), 1))];
    end
    SequenceWave(1, DevPosAll) = {Dev_Wave.Wave};
    SequenceWave(1, cellfun(@isempty, SequenceWave(1, :))) = {Std_Wave.Wave};
    for wavepieceIdx = 1:size(SequenceWave,2)
        if ismember(wavepieceIdx, DevPosAll); SequenceStruct = [SequenceStruct;Dev_Wave];else SequenceStruct = [SequenceStruct;Std_Wave];end
    end
else
    % manystd
    for cycle = 1 : RepNum
        StdRandomIdx = randperm(StdNum);
        DevRandomIdx = randperm(DevNum);
        SequenceWave(1, (cycle - 1)*(StdNum + DevNum) + [1:StdNum]) = {Std_Wave(StdRandomIdx).Wave};
        SequenceWave(1, (cycle - 1)*(StdNum + DevNum) + [StdNum+1:StdNum+DevNum]) = {Dev_Wave(DevRandomIdx).Wave};
        for StdSeqIdx = 1 : numel(StdRandomIdx);SequenceStruct = [SequenceStruct;Std_Wave(StdRandomIdx(StdSeqIdx))];end
        for DevSeqIdx = 1 : numel(DevRandomIdx);SequenceStruct = [SequenceStruct;Dev_Wave(DevRandomIdx(DevSeqIdx))];end
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ISI > numel(Std_Wave(1).Wave)/res.fs*1000
    SequenceWave(2, :) = cellfun(@(x) {zeros(ceil(ISI / 1000 * res.fs) - numel(x), 1)}, SequenceWave(1, :));
    SequenceStruct = addfield(SequenceStruct, 'ISIWave', SequenceWave(2, :));
end

WaveTemp = [reshape(SequenceWave(:, 1:end-1), [], 1); SequenceWave(1, end)];
OnOffSeq = (1/res.fs +  [0; cumsum(cellfun(@numel, WaveTemp)) / res.fs]) * 1000;
OnOffIndex = cumsum([1; cellfun(@numel, WaveTemp)]);
res.Wave = cell2mat(WaveTemp);
res.StdDev_OnsetSeq = OnOffSeq(1:2:end); res.StdDev_OffsetSeq = OnOffSeq(2:2:end);
res.StdDev_OnsetIndex = OnOffIndex(1:2:end); res.StdDev_OffsetIndex = OnOffIndex(2:2:end);
res.StdTrainSampN = cellfun(@(stdSeq) numel(stdSeq), {Std_Wave.Wave});
res.DevTrainSampN = cellfun(@(devSeq) numel(devSeq), {Dev_Wave.Wave});
res.ITISeq = [SequenceStruct.ITIs];
res.FreqSeq = {SequenceStruct.freqpool}';
res.Interval = diff(res.StdDev_OnsetIndex);
res.SeqOffset = numel(res.Wave) / res.fs * 1000;
res.SeqStruct = SequenceStruct;
if ~contains(Seq_Tag, "ManyStd")
    if isequal(Std_Wave(1).freqpool, Dev_Wave.freqpool) & ~isequal(Std_Wave(1).ITIs, Dev_Wave.ITIs)
        res.Name = strcat(Seq_Tag, "_StdITI", strrep(num2str(Std_Wave(1).ITIs), ".", "o"), "_DevITI", strrep(num2str(Dev_Wave.ITIs), ".", "o"),...
           "_Freq", strjoin(string(fix(Std_Wave(1).freqpool([1,end]))), "-"), "_ISI-", num2str(ISI), "ms_StdDur-", num2str(round(Std_Wave(1).Duration))...
            , "ms_StdNum-", num2str(StdNum), ".wav");
    elseif ~isequal(Std_Wave(1).freqpool, Dev_Wave.freqpool) & isequal(Std_Wave(1).ITIs, Dev_Wave.ITIs)
        fRatio = roundn(unique(Dev_Wave.freqpool/Std_Wave(1).freqpool), -2);
        res.Name = strcat(Seq_Tag, "_StdITI", strrep(num2str(Std_Wave(1).ITIs), ".", "o"), "_DevITI", strrep(num2str(Dev_Wave.ITIs), ".", "o"),...
           "_Freq", strjoin(string(fix(Std_Wave(1).freqpool([1,end]))), "-"), "_fRatio-", strrep(string(fRatio), ".", "o"),...
           "_ISI-", num2str(ISI), "ms_StdDur-", num2str(round(Std_Wave(1).Duration)),...
           "ms_StdNum-", num2str(StdNum), ".wav");   
    end
else
    res.Name = strcat(Seq_Tag, ".wav");
end

