function sounds = MMN_External_Sound_Gen(MSTIParams)

parseStruct(MSTIParams);
%% save folder
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

%% validate parameters
% sequence setting
soundPool = clickTrainCheckFcn(SoundPath);
selectSounds = soundPool(matches(string({soundPool.name}'), SoundSelect));
randSounds = soundPool(matches(string({soundPool.name}'), SoundRand));

% S1-S2
soundSeq = [repmat(selectSounds(1), stdNum, 1); selectSounds(2)];
sounds(1) = merge_External_Sequence(soundSeq, "Seq_Tag", "S1_S2", "ISI", ISI, "fs", fs);

% S2-S1
soundSeq = [repmat(selectSounds(2), stdNum, 1); selectSounds(1)];
sounds(2) = merge_External_Sequence(soundSeq, "Seq_Tag", "S2_S1", "ISI", ISI, "fs", fs);

if stdNum > length(randSounds)
    ncycles = floor(stdNum / length(randSounds));
    idx = [repmat(1:length(randSounds), 1, ncycles), randperm(length(randSounds), stdNum-ncycles * length(randSounds))]';
    idx = idx(randperm(length(idx)));
else
    idx = randperm(length(randSounds), stdNum-length(randSounds))';
end
% Rand-S2
soundSeq = [randSounds(idx); selectSounds(2)];
sounds(3) = merge_External_Sequence(soundSeq, "Seq_Tag", "ManyStd_S2", "ISI", ISI, "fs", fs);

% Rand-S1
soundSeq = [randSounds(idx); selectSounds(1)];
sounds(4) = merge_External_Sequence(soundSeq, "Seq_Tag", "ManyStd_S1", "ISI", ISI, "fs", fs);

%% export
mkdir(rootPath);
for sIndex = 1 : length(sounds)
    audiowrite(strcat(rootPath, "\Reg_", sounds(sIndex).Tag, ".wav"), sounds(sIndex).Wave, sounds(sIndex).fs);
end
save(fullfile(rootPath, "sounds.mat"), "sounds");
end
