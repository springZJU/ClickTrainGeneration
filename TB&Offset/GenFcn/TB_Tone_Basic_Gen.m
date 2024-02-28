function sounds = TB_Tone_Basic_Gen(TBOffsetParams)
parseStruct(TBOffsetParams);

%% validate input
if numel(S1Dur) > 1
    error("length of S1Dur should not larger than 1")
end

rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
mkdir(rootPath);
riseFallTime = 10; % ms
toneLength = S1Dur+S2Dur;
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
    [wave1, wave2] = TBToneBasic(f1(index), f2(index), S1Dur, S2Dur, fs);
    wave1 = Amp * wave1;
    wave2 = Amp * wave2;
    wave1(tR) = wave1(tR) .* sigRise;
    wave1(tF) = wave1(tF) .* sigFall;
    wave2(tR) = wave2(tR) .* sigRise;
    wave2(tF) = wave2(tF) .* sigFall;

 
    wave1Str = strcat(num2str(fix(f1(index))), "_", num2str(fix(f2(index))) , "_PT.wav");
    wave2Str = strcat(num2str(fix(f2(index))), "_", num2str(fix(f1(index))) , "_PT.wav");

    % save sound

    audiowrite(fullfile(rootPath, wave1Str), wave1, fs);
    audiowrite(fullfile(rootPath, wave2Str), wave2, fs);

    timeLength1 = S1Dur;
    timeLength2 = S2Dur;

    stimStr{index, 1} = strcat(num2str(fix(f1(index))), "o", num2str(fix(f2(index))));
    tone1Duration{index, 1} = timeLength1;
    tone2Duration{index, 1} = timeLength2;
end
sounds = struct("stimStr", stimStr, "tone1Duration", tone1Duration, "tone2Duration", tone2Duration);
if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds", "-mat");
end