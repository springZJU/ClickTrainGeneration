clear;clc;
fs = 97656;
%--------------------------to generate single click------------
clickDur = 20;
riseFallTime = 3;
Amp = 0.5;

clickDurN = ceil(clickDur/1000*fs);
riseFallN = ceil(riseFallTime/1000*fs);
clickOnN = clickDurN - 2*riseFallN;

sigOn = Amp*ones(1,clickOnN);
sigRise = Amp*((sin(pi*(0:1/(riseFallN-1):1)-0.5*pi)+1)/2);
sigFall = Amp*((sin(pi*(0:1/(riseFallN-1):1)+0.5*pi)+1)/2);
signal = [sigRise sigOn sigFall];

%--------------------------to generate single regular click train------------
soundLength = 300;
ICIs = 33.3;

clickDurN = ceil(clickDur / 1000 * fs); % sample points of click
regICISampN = repmat(ceil(ICIs / 1000 * fs), length(soundLength), 1); % number of sample points of each ICI
repeatTime = reshape(round(soundLength' ./ ICIs), [], 1); % repeat time of clicks for each click train 

% number of sample points for each click train
if ~exist("regClickTrainSampN", "var")
    regClickTrainSampN = cellfun(@(x) ones(x(1), 1) * x(2), num2cell([repeatTime, regICISampN], 2), 'UniformOutput', false);
end
% the index of rise edge for each click onset
clickOnEdgeIdx =cellfun(@(x) [0; cumsum(x)], regClickTrainSampN, 'UniformOutput', false);

for n = 1 : length(regICISampN)
    wave{n} = zeros(1, ceil(max(clickOnEdgeIdx{n})));
    clickIdx = cellfun(@(x) x+1:1:x+clickDurN, num2cell(clickOnEdgeIdx{n}),'UniformOutput',false);
    for clickN = 1 : length(clickIdx) - 1
        wave{n}(clickIdx{clickN}) = signal;
    end
    wave{n} = wave{n}';
    duration(n, 1) = find(wave{n} ~= 0, 1, 'last' ) / fs * 1000;
end
wave = wave';
[Amp, freq, ~, ~] = mfft(wave{1}, fs);
t = 1/fs : 1/fs : size(wave{1}, 1) / fs;

% 设计带通滤波器   
f1 = 1000;   % 通带下限频率  
f2 = 2000;  % 通带上限频率  
Wn = [f1 f2] / (fs/2); % 归一化截止频率  
% 设计4阶Butterworth带通滤波器  
[b, a] = butter(4, Wn, 'bandpass');  
wavefilte = filter(b, a, wave{1});
[Ampfilte, freqfilte, ~, ~] = mfft(wavefilte, fs);

% plot
figure;
subplot(2,2,1);
plot(t, wave{1});% raw
title("raw wave")
subplot(2,2,3);
plot(freq, Amp);% raw wave fft
title("rawwave fft");
xlim([0, 50]);
subplot(2,2,2);
plot(t, wavefilte);% filte wave
title("filte wave");
subplot(2,2,4);
plot(freqfilte, Ampfilte);% filte wave fft
xlim([0, 50]);
title("filte wave fft");
