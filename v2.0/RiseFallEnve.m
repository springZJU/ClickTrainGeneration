function riseFallEnve = RiseFallEnve(soundDur, riseFallTime, fs)
if soundDur <= 2 * riseFallTime
    error("total length should longer than 2 * riseFallTime!")
end
t = 1/fs : 1 /fs : (soundDur / 1000);
% calculate rise fall index
tR = find(t*1000 < riseFallTime);
tF = find(t*1000 > (soundDur - riseFallTime));
riseFallR = length(tR);
riseFallN = length(tF);
if riseFallTime
    tR(end) = [];
    tF(1) = [];
end
riseFallEnve = ones(1, length(t));
sigRise = 1*((sin(pi*(0:1/(riseFallR-1):(1 - 1/(riseFallR-1)))-0.5*pi)+1)/2);
sigFall = 1*((sin(pi*(0:1/(riseFallN-1):(1 - 1/(riseFallN-1)))+0.5*pi)+1)/2);
riseFallEnve(tR) = riseFallEnve(tR) .* sigRise;
riseFallEnve(tF) = riseFallEnve(tF) .* sigFall;

end
