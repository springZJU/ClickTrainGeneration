function dataNew = pickUpHeadTail(data, ratio, type)
    if numel(data) > length(data)
        error("please input a vector");
    end

    if size(data, 2) > 1
       data = data';
    end

    dataOrd = data;
    dataRev = flip(data);
    contSum = sum(data);

    if strcmpi(type, "length")
    lengthRaw = length(data);
    lengthNew = lengthRaw * ratio * 0.5;
    dataNew = [dataOrd(1 : lengthNew); flip(dataRev(1 : lengthNew))];
    elseif strcmpi(type, "cumsum")
        cutOff = contSum * ratio * 0.5;
        idxOrd = cumsum(dataOrd) <= cutOff;
        idxRev = cumsum(dataRev) <= cutOff;
        dataNew = [dataOrd(idxOrd); flip(dataRev(idxRev))];
    end
end

        