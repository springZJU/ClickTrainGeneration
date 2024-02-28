fs           = 97656; % 采样率100kHz
duration     = 0.5; % 信号持续时间0.5秒
riseFallTime = 5; % ms

% 生成risefall envelope
riseFallEnve = RiseFallEnve(duration*1000, 5, fs);

% 一个纯音例子用于声强校正
f_center = 1000;
t = 0:1/fs:duration-1/fs;
tone = 0.1*cos(2*pi*f_center*t);
rms_Tone = rms(tone);

% 生成白噪声
numSamples = fix(duration * fs); % 总样本数
noise = randn(numSamples, 1);
noise = riseFallEnve' .* noise * rms_Tone / rms(noise);

audiowrite('white noise.wav', noise, fs);

% 生成BPN
fc = 125*2.^(1:8);
cellfun(@(x) BPN(noise, fs, x, 1, rms_Tone, riseFallEnve), num2cell(fc)', "UniformOutput", false);
cellfun(@(x) BPN(noise, fs, x, 1/3, rms_Tone, riseFallEnve), num2cell(fc)', "UniformOutput", false);
% 生成纯音
cellfun(@(x) Tone(fs, x, duration, riseFallEnve), num2cell(fc)', "UniformOutput", false);


function BPN(noise, fs, f_center, octave, rms_Ref, riseFallEnve)
f_lower = f_center / 2^(octave/2); % 下限频率
f_upper = f_center * 2^(octave/2); % 上限频率
N = 100; % FIR滤波器的阶数

% 设计FIR带通滤波器
b = fir1(N, [f_lower f_upper]/(fs/2), 'bandpass');
a = 1; % FIR滤波器的a系数始终为1

% 应用滤波器
filtered_signal = filter(b, a, noise);
filtered_signal = riseFallEnve' .* filtered_signal * rms_Ref / rms(filtered_signal);
audiowrite(['BPN_fc_', num2str(f_center), '_Octave_', num2str(octave), '.wav'], filtered_signal, fs);
% audiowrite(['BPN_fc_', num2str(f_center), '_Octave_', num2str(rats(octave, ~isinteger(octave)*2+1)), '.wav'], filtered_signal, fs);
end

function RMS = Tone(fs, f_center, duration, riseFallEnve)
t = 0:1/fs:duration-1/fs;
tone = riseFallEnve .* cos(2*pi*f_center*t);
RMS = rms(tone);
audiowrite(['Tone_fs_', num2str(f_center),'.wav'], tone, fs);
end
