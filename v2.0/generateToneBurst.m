%--------------------------to generate single complex tone------------
function signal = generateToneBurst(opts)
parseStruct(opts);

% generate complex tone
freqPool = round(logspace(log10(BFScale(1)), log10(BFScale(2)), BFNum)');
clickDurN = ceil(clickDur/1000*fs);
T = 1/fs : 1/fs : clickDurN/fs;
riseFallEnvelope = RiseFallEnve(clickDur, toneRiseFall, fs);
pieces = cellfun(@(x) cos(2*pi*x*T), num2cell(freqPool), "uni", false);
signal = riseFallEnvelope.*sum(cell2mat(pieces));
signal = signal/max(abs(signal));
end