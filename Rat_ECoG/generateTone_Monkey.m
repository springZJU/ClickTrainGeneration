clear; clc;
mPath = mfilename("fullpath");
cd(fileparts(mPath));
Amp = 1;
fs = 97656;
toneLength = 3000; % ms
cutLength = 4000; % ms
riseFallTime = 0; % ms

% rootPath = fullfile('..\ratSounds', datestr(now, "yyyy-mm-dd"));
% rootPath = fullfile('..\monkeySounds', datestr(now, "yyyy-mm-dd"));
rootPath = fullfile('..\..\ratSounds', strcat(datestr(now, "yyyy-mm-dd"), "_Tone"));

mkdir(fullfile(rootPath, 'interval 0'));
% InitializePsychSound
% PsychPortAudio('Close');
% pahandle = PsychPortAudio('Open', [], 1, 1, fs, 2);

f1 = [500,      500,    250,      250];
f2 = [492.6108, 333.33, 246.3054, 166.67];

for index = 1 : length(f2)
    t = 1/fs : 1 /fs : (toneLength / 1000);
    
    % calculate rise fall index
    tR = find(t*1000 < riseFallTime);
    tF = find(t*1000 > (toneLength - riseFallTime));
    riseFallR = length(tR);
    riseFallN = length(tF);
    if riseFallTime
        tR(end) = [];
        tF(1) = [];
    end
    sigRise = 1*((sin(pi*(0:1/(riseFallR-1):(1 - 1/(riseFallR-1)))-0.5*pi)+1)/2);
    sigFall = 1*((sin(pi*(0:1/(riseFallN-1):(1 - 1/(riseFallN-1)))+0.5*pi)+1)/2);

    % cut off last signals for each tone
    tone1 = Amp * sin(2 * pi * f1(index) * t);
    tone2 = Amp * sin(2 * pi * f2(index) * t);
    tone1(tR) = tone1(tR) .* sigRise;
    tone2(tF) = tone2(tF) .* sigFall;

%     [~, ~, zeroIdx1] = findZeroPoint(tone1); % cross zero point, NP
    [~, ind] = find(abs(tone1) < 1e-3 & tone1 - [tone1(2 : end) 0] < 0);
    tone1 = tone1(1 : ind(end));
    tone1(end) = 0;
%     [~, ~, zeroIdx2] = findZeroPoint(tone2);
    [~, ind] = find(abs(tone2) < 1e-3 & tone2 - [tone2(2 : end) 0] < 0);
    tone2 = tone2(1 : ind(end));
    tone2(end) = 0;

    % merge tone
    cutIndex = 1/fs : 1/fs : length([tone1 tone2]) / fs  < cutLength / 1000;
    wave1 = [tone1 tone2];
    wave1 = wave1(cutIndex);
    wave2 = [tone2 tone1];
    wave2 = wave2(cutIndex);

    % cut off last signals for merged tone
    [~, ~, zeroIdx1] = findZeroPoint(wave1); % cross zero point, NP
    wave1(zeroIdx1(end) : end) = [];
    [~, ~, zeroIdx2] = findZeroPoint(wave2);
    wave2(zeroIdx2(end) : end) = [];

    wave1Str = strcat(num2str(fix(f1(index))), "_", num2str(fix(f2(index))) , "_PT.wav");
    wave2Str = strcat(num2str(fix(f2(index))), "_", num2str(fix(f1(index))) , "_PT.wav");
    tone1Str = strcat("single", num2str(fix(f1(index))), "_PT.wav");
    tone2Str = strcat("single", num2str(fix(f2(index))), "_PT.wav");
    % save sound
    
    audiowrite(fullfile(rootPath, 'interval 0', wave1Str), wave1, fs);
    audiowrite(fullfile(rootPath, 'interval 0', wave2Str), wave2, fs);


    timeLength1 = length(tone1) / fs * 1000;
    timeLength2 = length(tone2) / fs * 1000;


    stimStr{index, 1} = strcat(num2str(fix(f1(index))), "o", num2str(fix(f2(index))));
    tone1Duration{index, 1} = timeLength1;
    tone2Duration{index, 1} = timeLength2;

end
toneOpts = struct("stimStr", stimStr, "tone1Duration", tone1Duration, "tone2Duration", tone2Duration);
save(fullfile(rootPath, "toneOpts.mat"), "toneOpts", "-mat");