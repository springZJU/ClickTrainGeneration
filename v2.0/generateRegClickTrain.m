%--------------------------to generate single regular click train------------
function [wave, duration, clickOnEdgeIdx, regClickTrainSampN] = generateRegClickTrain(opts)
parseStruct(opts);

if ~iscolumn(ICIs)
    ICIs = ICIs';
end

clickDurN = ceil(clickDur / 1000 * fs); % sample points of click
regICISampN = repmat(ceil(ICIs / 1000 * fs), length(soundLength), 1); % number of sample points of each ICI
repeatTime = reshape(round(soundLength' ./ ICIs), [], 1); % repeat time of clicks for each click train 

% number of sample points for each click train
if ~exist("regClickTrainSampN", "var")
    regClickTrainSampN = cellfun(@(x) ones(x(1), 1) * x(2), num2cell([repeatTime, regICISampN], 2), 'UniformOutput', false);
end
% the index of rise edge for each click onset
clickOnEdgeIdx =cellfun(@(x) [0; cumsum(x)], regClickTrainSampN, 'UniformOutput', false);

for n = 1 : length(ICIs)
    wave{n} = zeros(1, ceil(max(clickOnEdgeIdx{n})));
    clickIdx = cellfun(@(x) x+1:1:x+clickDurN, num2cell(clickOnEdgeIdx{n}),'UniformOutput',false);
    for clickN = 1 : length(clickIdx) - 1
        wave{n}(clickIdx{clickN}) = click;
    end
    wave{n} = wave{n}';
    duration(n, 1) = find(wave{n} == Amp, 1, 'last' ) / fs * 1000;
end
wave = wave';

