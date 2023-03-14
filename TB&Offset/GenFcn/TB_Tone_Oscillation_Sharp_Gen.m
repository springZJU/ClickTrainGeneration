function sounds = TB_Tone_Oscillation_Sharp_Gen(TBOffsetParams)


parseStruct(TBOffsetParams);

freqPool = round(logspace(log10(BFScale(1)), log10(BFScale(2)), BFNum)');
f1 = repmat(freqPool, length(S1Dur), 1);
f2 = f1*ratio;
Durs = reshape(repmat(S1Dur', length(freqPool), 1), [], 1);
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
mkdir(rootPath);

for index = 1 : length(f2)
    riseFallTime = 0; % ms
    toneLength = Durs(index);
    opts.fs = fs;
    opts.soundLength = toneLength; %
    opts.successiveDuration = SuccessiveDuration;

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

%   [~, ~, zeroIdx1] = findZeroPoint(tone1); % cross zero point, NP
%     [~, ind] = find(abs(tone1) < 1e-2 & tone1 - [tone1(2 : end) 0] < 0);
%     tone1 = tone1(1 : zeroIdx1(end));
    tone1(end) = 0;
%   [~, ~, zeroIdx2] = findZeroPoint(tone2);
%     [~, ind] = find(abs(tone2) < 1e-2 & tone2 - [tone2(2 : end) 0] < 0);
%     tone2 = tone2(1 : zeroIdx2(end));
    tone2(end) = 0;


    % merge tone
    wave1 = mergeSuccessiveTone(tone1, tone2, 0, opts, []);
    wave1Str = strcat(num2str(fix(f1(index))), "_Successive_PT.wav");

    % save sound
    audiowrite(fullfile(rootPath,  strcat(num2str(toneLength), "ms_", wave1Str)), wave1, fs);



    timeLength1 = length(tone1) / fs * 1000;
    timeLength2 = length(tone2) / fs * 1000;


    stimStr{index, 1} = strcat(num2str(fix(f1(index))), "o", num2str(fix(f2(index))));
    tone1Duration{index, 1} = timeLength1;
    tone2Duration{index, 1} = timeLength2;

end

sounds = struct("stimStr", stimStr, "tone1Duration", tone1Duration, "tone2Duration", tone2Duration);
save(fullfile(rootPath, "sounds.mat"), "sounds", "-mat");