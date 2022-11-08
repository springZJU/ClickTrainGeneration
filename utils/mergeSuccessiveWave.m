function res = mergeSuccessiveWave(s1Wave, s2Wave, interval, opts, s2CutOff)
% interval unit : ms
% if reverseFlag is true, the function conduct both s1s2 mergence and s2s1 mergence
narginchk(4, 5);
if nargin < 5
    s2CutOff = [];
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
    curoffIdx1 = cellfun(@(x) x(findZeroPoint(x / fs * 1000 - s2CutOff)), idxNP1, "uni", false);
    s1WaveCut = cellfun(@(x) x{1}(1 : x{2}), array2VectorCell([s1Wave curoffIdx1]), "UniformOutput", false);

    [~, ~, idxNP2] = cellfun(@(x) findZeroPoint(x), s2Wave, "uni", false);
    curoffIdx2 = cellfun(@(x) x(findZeroPoint(x / fs * 1000 - s2CutOff)), idxNP2, "uni", false);
    s2WaveCut = cellfun(@(x) x{1}(1 : x{2}), array2VectorCell([s2Wave curoffIdx2]), "UniformOutput", false);
else
    s1WaveCut = s1Wave;
    s2WaveCut = s2Wave;
end

segN = ceil(successiveDuration / soundLength) ; % N single wave
for iciIdx = 1 : length(s2Wave)
    temp = cell(segN, 2);
    if ~isempty(intSampN)
        temp(:, 2) = repmat({intSampN}, segN, 1);
    else
        temp(:, 2) = cell(segN, 1);
    end
    temp(1 : 2 : end, 1) = s1Wave(iciIdx);
    temp(2 : 2 : end, 1) = s2Wave(iciIdx);
    temp(1) = s1TailRep(iciIdx);
    if mod(segN, 2) == 1
        temp(end, 1) = s1HeadRep(iciIdx);
    else
        temp(end, 1) = s2HeadRep(iciIdx);
    end

    wave{iciIdx} = reshape(temp', 1, [])';
end



s1s2 = cellfun(@(x) cell2mat(x)', wave, "UniformOutput", false);
s1Duration = cellfun(@(x) find(x == 1, 1 , 'last') / fs * 1000, s1Wave, 'UniformOutput', false);
s1End = cellfun(@(x) length(x) / fs * 1000, s1Wave, 'UniformOutput', false);
s1Str = cellfun(@(x) strcat(num2str(x), 'ms'), num2cell(ICIs(1 : 2: end)) , 'UniformOutput', false);
s2Str = cellfun(@(x) strcat(num2str(x), 'ms'), num2cell(ICIs(2 : 2: end)) , 'UniformOutput', false);
res = struct('s1s2', s1s2', 's1Duration', s1Duration, 's1End', s1End, 's1Str', s1Str, 's2Str', s2Str, 'interval', num2cell(repmat(interval, size(s1Wave, 1), 1)));

end