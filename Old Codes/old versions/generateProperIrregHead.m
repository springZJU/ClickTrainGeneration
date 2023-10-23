clear ; clc

%% important parameters
s1ICI = [4, 4]; % ms
s2ICI = [4, 4.06];
opts.fs = 97656;
opts.Amp = 0.5;
opts.Amp1 = cellfun(@(x, y) normalizeClickTrainSPL(x, y, opts.Amp, 1), num2cell(s1ICI), num2cell(s2ICI), "UniformOutput", false);
opts.Amp2 = cellfun(@(x, y) normalizeClickTrainSPL(x, y, opts.Amp, 2), num2cell(s1ICI), num2cell(s2ICI), "UniformOutput", false);
opts.riseFallTime = 0; % ms
opts.clickDur = evalin("base", "clickDur") ; % ms
click = generateClick(opts);

Dur1 = 30; % ms
Dur2 = 60; % ms

%% for click train long term
opts.repN = 0; % 
opts.click = click;
opts.trainLength = 100; % ms, single train
opts.soundLength = 100; % ms, sound length, composed of N single trains
opts.ICIs = reshape([s1ICI; s2ICI], [], 1 ); % ms

opts.baseICI =  4; % ms
opts.sigmaPara = 2; % sigma = μ / sigmaPara

%% check 
Dur1 = 30; % ms
Dur2 = 60; % ms
temp = cell2mat(irregICISampN(opts));
idx1 = find(cumsum(temp) < ceil(Dur1 * opts.fs / 1000));
idx2 = find(cumsum(temp) < ceil(Dur2 * opts.fs / 1000));

while abs(diff([sum(temp(idx1))/opts.fs * 1000, Dur1])) > 0.5 ||  abs(diff([sum(temp(idx2))/opts.fs * 1000, Dur2])) > 1
    temp = cell2mat(irregICISampN(opts));
idx1 = find(cumsum(temp) < ceil(Dur1 * opts.fs / 1000));
idx2 = find(cumsum(temp) < ceil(Dur2 * opts.fs / 1000));
end
first100ms_IrregBase = temp;
