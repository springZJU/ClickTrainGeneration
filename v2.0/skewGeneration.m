function skewedData = skewGeneration(opts, irregICISampNBase)
narginchk(1, 2);
parseStruct(opts);
minValue = dataRange(1);
maxValue = dataRange(2);
while true
    % 生成正态分布数据
    originalData = normrnd(targetMean, targetStd, [length(irregICISampNBase), 1]);

    % 引入偏态：通过限制数据范围的方式简单引入偏态
    % 注意：这里仅为示例，实际操作可能需要更复杂的方法
    % 应用变换以引入偏态
    if strcmp(skewType, 'positive')
        % 正偏态变换
        transformedData = skewBase.^originalData;
    elseif strcmp(skewType, 'negative')
        % 负偏态变换
        transformedData = -skewBase.^(-originalData);
    else
        % 无变换
        transformedData = originalData;
    end
    % 调整以符合平均值和标准差
    adjustedData = (transformedData - mean(transformedData)) * (targetStd / std(transformedData)) + targetMean;

    % 再次确保数据范围符合要求
    adjustedData = min(max(adjustedData, minValue), maxValue);

    % 检查是否满足要求
    currentMean = mean(adjustedData);
    currentStd = std(adjustedData);

    % 验证数据是否满足特定条件
    if abs(currentMean - targetMean) / targetMean < 0.08 && abs(currentStd - targetStd) / targetStd < 0.08
        outputData = adjustedData;
        break; % 条件满足，退出循环
    end
    % 如果不满足条件，则循环继续，进行新一轮的生成和调整
end
skewedData = improveSmoothness(outputData);

% 最终校正，确保数据范围符合要求
if skewBase == 1
    skewedData = irregICISampNBase;
else
    skewedData = skewedData * fs / 1000 / (targetMean / basicICI);
end
% 最终验证输出数据的统计特性
fprintf('Final Mean: %f\n', mean(outputData));
fprintf('Final Std: %f\n', std(outputData));
end
function outputData = improveSmoothness(data)
    N = length(data); % 数据长度
    outputData = data; % 初始化输出数据

    % 计算原始数据的平均值和标准差，用于后续比较
    originalMean = mean(data);
    originalStd = std(data);
    
    % 为了减少局部极值，我们将数据点分为高值和低值两组
    medianValue = median(data);
    highValues = data(data > medianValue);
    lowValues = data(data <= medianValue);
    
    % 分别打乱高值和低值数组
    highValues = highValues(randperm(length(highValues)));
    lowValues = lowValues(randperm(length(lowValues)));
    
    % 交替重组数据以减少极值连续性，同时尝试保持整体分布
    for i = 1:N
        if mod(i, 2) == 0 && ~isempty(highValues)
            outputData(i) = highValues(1);
            highValues(1) = [];
        elseif ~isempty(lowValues)
            outputData(i) = lowValues(1);
            lowValues(1) = [];
        end
    end
    
    % 调整输出数据以匹配原始数据的平均值和标准差
    adjustedMean = mean(outputData);
    adjustedStd = std(outputData);
    scale = originalStd / adjustedStd;
    outputData = scale * (outputData - adjustedMean) + originalMean;
    
    % 确保数据在原始范围内
    outputData = min(max(outputData, min(data)), max(data));
end

