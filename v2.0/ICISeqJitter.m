function ICIJitter = ICISeqJitter(ICISeq, Jitter, JitterMethod)
if ~isempty(Jitter)
    pairN = floor(length(ICISeq)/2);
    ratioOdd = 1+randi(Jitter(2)-1, [pairN, 1])/100;
    ratioEven = 2-ratioOdd;
    switch JitterMethod
        case "EvenOdd"
            ratioOdd = ratioOdd(randperm(length(ratioOdd)));
            ratioEven = ratioEven(randperm(length(ratioEven)));
            ICIJitter = ICISeq;
            ICIJitter(1:2:end) = ICIJitter(1:2:end) .* ratioOdd;
            ICIJitter(2:2:end) = ICIJitter(2:2:end) .* ratioEven;
        case "rand"
            ratio = [ratioOdd; ratioEven];
            ratio = ratio(randperm(length(ratio)));
            ICIJitter = ICISeq .* ratio;
    end
    ICIJitter = ceil(ICIJitter);
else
    ICIJitter = ICISeq;
end

end