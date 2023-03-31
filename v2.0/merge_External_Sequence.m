function res = merge_External_Sequence(soundSeq, varargin)
mIp = inputParser;
mIp.addRequired("soundSeq", @(x) isstruct(x));
mIp.addParameter("Seq_Tag", [], @(x) any(validatestring(x, {'S1_S2', 'S2_S1', 'ManyStd_S2', 'ManyStd_S1'})));
mIp.addParameter("ISI", 1000, @(x) length(x) == 1 | length(x) == length(soundSeq));
mIp.addParameter("fs", soundSeq(1).fs, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.parse(soundSeq, varargin{:});
Seq_Tag = mIp.Results.Seq_Tag;
ISI = mIp.Results.ISI;
fs = mIp.Results.fs;

if length(ISI) ~= length(soundSeq)
    if length(ISI) == 1
        ISI = repmat(ISI, length(soundSeq), 1);
    else
        error("invalid ISI setting!")
    end
end
if ~iscolumn(ISI)
    ISI = ISI';
end
if any([soundSeq.interval]' > ISI)
    error("sound duration should not be greater than ISI !!!");
end
if isempty(Seq_Tag)
    error("Sequence Tag is missing!!!");
end



temp = zeros(round(sum(ISI)/1000*fs), 1);
posIdx = round(cumsum([1; ISI(1:end-1)/1000*fs]));
for p = 1 : length(posIdx)
    temp(posIdx(p) : posIdx(p)+length(soundSeq(p).y1)-1) = soundSeq(p).y1;
end
if iscolumn(temp)
    temp = temp';
end
res.Tag = Seq_Tag;
res.onsetSeq = [0; cumsum(ISI(1:end-1))];
res.Wave = temp;
res.ISISeq= ISI; 
res.fs= fs; 
res.soundSeq = soundSeq;



