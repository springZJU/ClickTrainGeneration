%--------------------------to generate single regular click train------------
function [wave, duration, clickOnEdgeIdx, regClickTrainSampN] = generateGradClickTrain(opts)
parseStruct(opts)
if ~iscolumn(ICIs)
    ICIs = ICIs';
end

clickDurN = ceil(clickDur / 1000 * fs); % sample points of click

if strcmpi(Type, "ascend")
    regClickTrainSampN = cellfun(@(x) round(linspace(ICIRangeRatio(1)*x/1000*fs, ICIRangeRatio(2)*x/1000*fs, soundLength/x))', num2cell(ICIs), "UniformOutput", false);
elseif strcmpi(Type, "descend")
    regClickTrainSampN = cellfun(@(x) flip(round(linspace(ICIRangeRatio(1)*x/1000*fs, ICIRangeRatio(2)*x/1000*fs, soundLength/x)))', num2cell(ICIs), "UniformOutput", false);
elseif strcmpi(Type, "ascend_Osci")
    regClickTrainSampN = cellfun(@(x) repmat([round(linspace(ICIRangeRatio(1)*x/1000*fs, ICIRangeRatio(2)*x/1000*fs, soundLength/x/(2*n_cycles))), ...
                                         flip(round(linspace(ICIRangeRatio(1)*x/1000*fs, ICIRangeRatio(2)*x/1000*fs, soundLength/x/(2*n_cycles))))], 1, n_cycles)', ...
                                         num2cell(ICIs), "UniformOutput", false);
elseif strcmpi(Type, "descend_Osci")
    regClickTrainSampN = cellfun(@(x) repmat([flip(round(linspace(ICIRangeRatio(1)*x/1000*fs, ICIRangeRatio(2)*x/1000*fs, soundLength/x/(2*n_cycles)))), ...
                                         round(linspace(ICIRangeRatio(1)*x/1000*fs, ICIRangeRatio(2)*x/1000*fs, soundLength/x/(2*n_cycles)))], 1, n_cycles)', ...
                                         num2cell(ICIs), "UniformOutput", false);
elseif strcmpi(Type, "regular")
    regClickTrainSampN = cellfun(@(x) round(linspace(x/1000*fs, x/1000*fs, soundLength/x))', num2cell(ICIs), "UniformOutput", false);
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
