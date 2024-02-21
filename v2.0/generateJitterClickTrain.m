%--------------------------to generate single jitter click train------------
function [wave, duration, clickOnEdgeIdx] = generateJitterClickTrain(opts)
parseStruct(opts);

if size(ICIs, 1) == 1
    ICIs = ICIs';
end

clickDurN = ceil(clickDur / 1000 * fs); % sample points of click
% number of sample points for each click train
clickOnEdgeIdx =cellfun(@(x) [0; cumsum(x)], regClickTrainSampN, 'UniformOutput', false);
for n = 1 : length(ICIs)
    wave{n} = zeros(1, ceil(max(clickOnEdgeIdx{n})));
    clickIdx = cellfun(@(x) x+1:1:x+clickDurN, num2cell(clickOnEdgeIdx{n}),'UniformOutput',false);
    for clickN = 1 : length(clickIdx) - 1
        wave{n}(clickIdx{clickN}) = click;
    end
    wave{n} = wave{n}';
    duration(n, 1) = find(wave{n} ~= 0, 1, 'last' ) / fs * 1000;
end
wave = wave';
