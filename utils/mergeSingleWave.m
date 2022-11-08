function res = mergeSingleWave(s1Wave, s2Wave, interval, opts, reverseFlag, s2CutOff, s1CutOff)
% interval unit : ms
% if reverseFlag is true, the function conduct both s1s2 mergence and s2s1 mergence
narginchk(4, 7);
if nargin < 5
    reverseFlag = 0;
    s2CutOff = [];
    s1CutOff = [];
end

if nargin < 6
    s2CutOff = [];
    s1CutOff = [];
end

if nargin < 7
    s1CutOff = [];
end
optsNames = fieldnames(opts);
for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end


intSampN = zeros(ceil(interval / 1000 * fs), 1);

if ~isempty(s2CutOff)
    if s2CutOff > soundLength
        error("cutOff should shorter than SoundLength !!!");
    end
    [~, ~, idxNP1] = cellfun(@(x) findZeroPoint(x), s1Wave, "uni", false);
    cutoffIdx1 = cellfun(@(x) x(findZeroPoint(x / fs * 1000 - s2CutOff)), idxNP1, "uni", false);
    s2Wave1Cut = cellfun(@(x) x{1}(1 : x{2}), array2VectorCell([s1Wave cutoffIdx1]), "UniformOutput", false);

    [~, ~, idxNP2] = cellfun(@(x) findZeroPoint(x), s2Wave, "uni", false);
    curoffIdx2 = cellfun(@(x) x(findZeroPoint(x / fs * 1000 - s2CutOff)), idxNP2, "uni", false);
    s2Wave2Cut = cellfun(@(x) x{1}(1 : x{2}), array2VectorCell([s2Wave curoffIdx2]), "UniformOutput", false);
else
    s2Wave1Cut = s1Wave;
    s2Wave2Cut = s2Wave;
end

if ~isempty(s1CutOff)
    if s1CutOff > soundLength
        error("cutOff should shorter than SoundLength !!!");
    end
    [~, ~, idxNP1] = cellfun(@(x) findZeroPoint(x), s1Wave, "uni", false);
    cutoffIdx1 = cellfun(@(x) x(findZeroPoint(x / fs * 1000 - s1CutOff)), idxNP1, "uni", false);
    s1Wave1Cut = cellfun(@(x) x{1}(1 : x{2}), array2VectorCell([s1Wave cutoffIdx1]), "UniformOutput", false);

    [~, ~, idxNP2] = cellfun(@(x) findZeroPoint(x), s2Wave, "uni", false);
    curoffIdx2 = cellfun(@(x) x(findZeroPoint(x / fs * 1000 - s1CutOff)), idxNP2, "uni", false);
    s1Wave2Cut = cellfun(@(x) x{1}(1 : x{2}), array2VectorCell([s2Wave curoffIdx2]), "UniformOutput", false);
else
    s1Wave1Cut = s1Wave;
    s1Wave2Cut = s2Wave;
end

s1s2 = cellfun(@(x) [x{1}; intSampN; x{2}], array2VectorCell([s1Wave1Cut s2Wave2Cut]), 'UniformOutput', false);
s1Duration = cellfun(@(x) find(x == 1, 1 , 'last') / fs * 1000, s1Wave1Cut, 'UniformOutput', false);
s1End = cellfun(@(x) length(x) / fs * 1000, s1Wave1Cut, 'UniformOutput', false);
s1Str = cellfun(@(x) strcat(num2str(x), 'ms'), num2cell(ICIs(1 : 2: end)) , 'UniformOutput', false);
s2Str = cellfun(@(x) strcat(num2str(x), 'ms'), num2cell(ICIs(2 : 2: end)) , 'UniformOutput', false);
res = struct('s1s2', s1s2, 's1Duration', s1Duration, 's1End', s1End, 's1Str', s1Str, 's2Str', s2Str);

if reverseFlag
    s2s1 = cellfun(@(x) [x{1}; x{2}], array2VectorCell([s1Wave2Cut s2Wave1Cut]), 'UniformOutput', false);
    s2Duration = cellfun(@(x) find(x == 1, 1 , 'last') / fs * 1000, s1Wave2Cut, 'UniformOutput', false);
    s2End = cellfun(@(x) length(x) / fs * 1000, s1Wave2Cut, 'UniformOutput', false);
    res = addFieldToStruct(res, [s2s1 s2Duration s2End], {'s2s1'; 's2Duration'; 's2End'});
end



end