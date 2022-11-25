%--------------------------to generate single irregulawave{i, 1}r click train------------
function [wave, duration, clickOnEdgeIdx, irregICISampN] = generateIrregClickTrain(opts)
optsNames = fieldnames(opts);
for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end

clickDurN = ceil(clickDur / 1000 * fs); % sample points of click

irregICISampN = cell(length(ICIs), 1);
wave = cell(length(ICIs), 1);
duration = zeros(length(ICIs), 1);
for i = 1 : length(ICIs)
    temp = irregICISampNBase * ICIs(i) / opts.baseICI;
    
    % pick up head and tail data
    irregICISampN{i, 1} = pickUpHeadTail(temp,  soundLength/1000*fs / sum(temp), "cumsum");
    
    clickOnEdgeIdx = [0; cumsum(irregICISampN{i, 1})];
    clickIdx = cellfun(@(x) x+1:1:x+clickDurN,num2cell(ceil(clickOnEdgeIdx)),'UniformOutput',false);
    wave{i, 1} = zeros(1, ceil(max(clickOnEdgeIdx)));
    for j = 1 : length(clickIdx)-1
        wave{i, 1}(clickIdx{j}) = click;
    end
    wave{i, 1} = wave{i, 1}';
    duration(i, 1) = find(wave{i, 1} == Amp, 1, 'last' ) / fs * 1000;
end

end
