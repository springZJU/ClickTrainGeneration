function riseFallEnve = RiseFallEnve(soundDur, riseFallTime, fs)
if soundDur <= 2 * riseFallTime
    error("total length should longer than 2 * riseFallTime!")
end
onDurN = ceil(soundDur/1000*fs);
riseFallN = ceil(riseFallTime/1000*fs);
OnN = onDurN - 2*riseFallN;

sigOn = ones(1,OnN);
sigRise = (sin(pi*(0:1/(riseFallN-1):1)-0.5*pi)+1)/2;
sigFall = (sin(pi*(0:1/(riseFallN-1):1)+0.5*pi)+1)/2;
riseFallEnve = [sigRise sigOn sigFall];

end
