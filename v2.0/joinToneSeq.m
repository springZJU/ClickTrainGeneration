function signal = joinToneSeq(frequencies, sampleCounts, fs)
    % frequencies: 频率数组，单位为 Hz
    % sampleCounts: 对应的采样点数组
    % fs: 采样率，单位为 Hz

    % 初始化信号
    totalSamples = sum(sampleCounts);
    signal = zeros(1, totalSamples);

    % 初始化相位
    phi = 0;
    currentIndex = 1;

    % 生成每段信号并连接
    for i = 1:length(frequencies)
        f = frequencies(i);
        n = sampleCounts(i); % 当前段信号的采样点数
        t = (0:n-1) / fs; % 时间向量

        % 生成当前段信号并考虑初始相位
        s = sin(2 * pi * f * t + phi);

        % 更新相位，保证相邻段信号相位连续
        segDur = n / fs; % 当前段信号的持续时间（秒）
        phi = mod(phi + 2 * pi * f * segDur, 2 * pi);

        % 将当前段信号连接到输出信号中
        signal(currentIndex:currentIndex + n - 1) = s;
        currentIndex = currentIndex + n;
    end
end
