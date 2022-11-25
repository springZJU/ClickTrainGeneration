
clearvars -except Amp cutLength toneLength f1 f2 singleLength folderName
mPath = mfilename("fullpath");
cd(fileparts(mPath));


fs = 97656;


riseFallTime = 0; % ms

opts.fs = fs;
opts.soundLength = toneLength; % 
opts.successiveDuration = singleLength;

 rootPath = fullfile('..\..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));


mkdir(fullfile(rootPath, 'successive interval 0'));
% InitializePsychSound
% PsychPortAudio('Close');
% pahandle = PsychPortAudio('Open', [], 1, 1, fs, 2);



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
    [~, ind] = find(abs(tone1) < 1e-2 & tone1 - [tone1(2 : end) 0] < 0);
    tone1 = tone1(1 : ind(end));
    tone1(end) = 0;
%     [~, ~, zeroIdx2] = findZeroPoint(tone2);
    [~, ind] = find(abs(tone2) < 1e-2 & tone2 - [tone2(2 : end) 0] < 0);
    tone2 = tone2(1 : ind(end));
    tone2(end) = 0;


    % merge tone
    wave1 = mergeSuccessiveTone(tone1, tone2, 0, opts, []);

    wave1Str = strcat(num2str(fix(f1(index))), "_", num2str(fix(f2(index))), "_Successive_PT_", num2str(toneLength), ".wav");

    % save sound
    audiowrite(fullfile(rootPath, 'successive interval 0', strcat(num2str(toneLength), "ms_", wave1Str)), wave1, fs);



    timeLength1 = length(tone1) / fs * 1000;
    timeLength2 = length(tone2) / fs * 1000;


    stimStr{index, 1} = strcat(num2str(fix(f1(index))), "o", num2str(fix(f2(index))));
    tone1Duration{index, 1} = timeLength1;
    tone2Duration{index, 1} = timeLength2;

end
toneOpts = struct("stimStr", stimStr, "tone1Duration", tone1Duration, "tone2Duration", tone2Duration);
save(fullfile(rootPath, "toneOpts.mat"), "toneOpts", "-mat");