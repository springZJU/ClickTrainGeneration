function [signal1, signal2] = TBToneBasic(f1, f2, Dur1, Dur2, fs)
% 设置参数
% fs = 97656; % 采样率
Dur1 = Dur1/1000; % 输入的segDur以ms为单位
Dur2 = Dur2/1000;
% 生成两个相位连续的正弦信号
n1 = round(Dur1*fs); % 采样点数
t1 = (0:n1-1)/fs; % 时间向量
n2 = round(Dur2*fs); % 采样点数
t2 = (0:n2-1)/fs; % 时间向量
phi = 0; % 初始相位为0


%% S1S2
s1 = sin(2*pi*f1*(t1 + phi)); % 第一个信号
phi = mod(phi + 2*pi*f1*Dur1, 2*pi); % 更新相位，使得两个信号之间相位连续
% phi = angle(s1(end-1));
s2 = sin(2*pi*f2*t2 + phi); % 第二个信号
% 将两个信号交替排列
signal1 = [s1, s2];

%% S2S1
phi = 0;
s2 = sin(2*pi*f2*(t1 + phi)); % 第一个信号
phi = mod(phi + 2*pi*f2*Dur1, 2*pi); % 更新相位，使得两个信号之间相位连续
% phi = angle(s1(end-1));
s1 = sin(2*pi*f1*t2 + phi); % 第二个信号
% 将两个信号交替排列
signal2 = [s2, s1];
