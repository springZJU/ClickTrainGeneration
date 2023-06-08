function signal = joinTone(f1, f2, segDur, wholeDur, fs)
% 设置参数
% fs = 97656; % 采样率
segDur = segDur/1000; % 输入的segDur以ms为单位
% f1 = 440; % 第一个音频的频率为440Hz
% f2 = 880; % 第二个音频的频率为880Hz

% 生成两个相位连续的正弦信号
n = round(segDur*fs); % 采样点数
t = (0:n-1)/fs; % 时间向量
phi = 0; % 初始相位为0
s1 = sin(2*pi*f1*(t + phi)); % 第一个信号
phi = mod(phi + 2*pi*f1*segDur, 2*pi); % 更新相位，使得两个信号之间相位连续
% phi = angle(s1(end-1));
s2 = sin(2*pi*f2*t + phi); % 第二个信号

% 将两个信号交替排列
signal = zeros(1, round(10*segDur*fs)); % 初始化输出信号
repN = round(wholeDur/1000/2/segDur);
for ii = 1:repN
    idx1 = (2*ii-2)*n + 1; % 第一个信号的起始位置
    idx2 = (2*ii-1)*n; % 第一个信号的结束位置
    signal(idx1:idx2) = s1; % 将第一个信号复制到输出信号中
    phi = mod(phi + 2*pi*f2*segDur, 2*pi); % 更新相位，使得相邻信号之间相位连续
%     phi = angle(s2(end));
    s1 = sin(2*pi*f1*t + phi); % 生成下一个第一个信号
    signal(idx2+1:idx2+n) = s2; % 将第二个信号复制到输出信号中
    phi = mod(phi + 2*pi*f1*segDur, 2*pi); % 更新相位，使得相邻信号之间相位连续
%     phi = angle(s1(end));
    s2 = sin(2*pi*f2*t + phi); % 生成下一个第二个信号
end
