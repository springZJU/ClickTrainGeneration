%--------------------------to generate single complex tone------------
function signal = mgenerateToneBurst(opts)
parseStruct(opts);

% generate complex tone
clickDurN = ceil(clickDur/1000*fs);
T = 1/fs : 1/fs : clickDurN/fs;
riseFallEnvelope = RiseFallEnve(clickDur, toneRiseFall, fs);
pieces = cellfun(@(x) cos(2*pi*x*T), num2cell(freqpool), "uni", false);
if iscolumn(freqpool)
    signal = riseFallEnvelope.*sum(cell2mat(pieces));
elseif isrow(freqpool)
    signal = riseFallEnvelope.*sum(cell2mat(pieces'));
end
signal = signal/max(abs(signal));
end