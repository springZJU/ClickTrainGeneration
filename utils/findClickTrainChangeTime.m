function Idx = findClickTrainChangeTime(interval, probeLRatio)
for sIndex = 1 : length(interval)
    temp = interval{sIndex};
    probeLength = ceil(length(temp) * probeLRatio);
    probe = temp(1 : probeLength);
    [r, lags] = xcorr(temp, probe);
    r(lags<0) = [];
    r(end - probeLength : end) = [];
    r = r / std(diff(r));
    idx = [];
    diffMax = 0;
    while isempty(idx) && diffMax > -100
        diffMax = diffMax - 0.1;
        idx = find([0; diff(diff(r))] < diffMax * std(diff(r)));
    end

    while length(idx) > 1 && diffMax > -100
        diffMax = diffMax + 0.01;
        idx =  find(diff(diff(r)) < diffMax * std(diff(r)));
    end

    if diffMax == -100
        idx = [];
    end

    if ~mode(diff(r))
        idx = idx - probLength;
    end
    Idx(sIndex) = idx;
end

plot(r);



