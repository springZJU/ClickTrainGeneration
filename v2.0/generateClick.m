%--------------------------to generate single click------------
function signal = generateClick(opts)
parseStruct(opts);

clickDurN = ceil(clickDur/1000*fs);
riseFallN = ceil(riseFallTime/1000*fs);
clickOnN = clickDurN - 2*riseFallN;

sigOn = Amp*ones(1,clickOnN);
sigRise = Amp*((sin(pi*(0:1/(riseFallN-1):1)-0.5*pi)+1)/2);
sigFall = Amp*((sin(pi*(0:1/(riseFallN-1):1)+0.5*pi)+1)/2);
signal = [sigRise sigOn sigFall];
end