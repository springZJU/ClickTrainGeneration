function ICIJitter = ICISeqJitter(ICISeq, Jitter, JitterMethod)
if ~isempty(Jitter)
    pairN = floor(length(ICISeq)/2);
    if Jitter(1) == Jitter(2)
        ratioOdd = ones(pairN, 1) * (1+Jitter(1)/100);
    else
        ratioOdd = 1+randi(Jitter(2)-1, [pairN, 1])/100;
    end
    ratioEven = 2-ratioOdd;

    switch JitterMethod
        case "EvenOdd"
            ratioOdd = ratioOdd(randperm(length(ratioOdd)));
            ratioEven = ratioEven(randperm(length(ratioEven)));
            ICIJitter = ICISeq;
            ICIJitter(1:2:end) = ICIJitter(1:2:end) .* [ratioOdd; ones(length(ICIJitter(1:2:end))- length(ratioOdd), 1)];
            ICIJitter(2:2:end) = ICIJitter(2:2:end) .* [ratioEven; ones(length(ICIJitter(2:2:end))- length(ratioOdd), 1)];
        case "rand"
            ratio = [ratioOdd; ratioEven];
            ratio = ratio(randperm(length(ratio)));
            ICIJitter = ICISeq .* ratio;
        case "sumConstant"
            ICIJitter = ICISeq;
            ICIJitter(1:2:end) = ICIJitter(1:2:end) .* [ratioOdd; ones(length(ICIJitter(1:2:end))- length(ratioOdd), 1)];
            ICIJitter(2:2:end) = ICIJitter(2:2:end) .* [ratioEven; ones(length(ICIJitter(2:2:end))- length(ratioOdd), 1)];

    end
    ICIJitter = ceil(ICIJitter);
else
    ICIJitter = ICISeq;
end

end