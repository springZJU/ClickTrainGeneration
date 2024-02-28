function wave = ICISeq2ClickTrain(ICISeq, clickDur, fs, Amp)
    narginchk(2, 4);
    if nargin < 3
        fs = 97656;
    end
    if nargin < 4
        Amp = 0.5;
    end
    opts.clickDur = clickDur;
    opts.fs = fs;
    opts.riseFallTime = 0;
    opts.Amp = Amp;

    clickDurN = ceil(clickDur/1000*fs);
    click = generateClick(opts);
    clickOnEdgeIdx = [0; cumsum(ICISeq)];
    clickIdx = cellfun(@(x) x+1:1:x+clickDurN,num2cell(ceil(clickOnEdgeIdx)),'UniformOutput',false);
    wave = zeros(1, ceil(max(clickOnEdgeIdx)));
    for j = 1 : length(clickIdx)-1
        wave(clickIdx{j}) = click;
    end
    wave = [wave, click];
    wave = wave';
end