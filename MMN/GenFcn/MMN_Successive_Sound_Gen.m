function sounds = MMN_Successive_Sound_Gen(MSTIParams)

parseStruct(MSTIParams);
%% save folder
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

%% validate parameters
% sequence setting
soundPool = clickTrainCheckFcn(SoundPath);
selectSounds = soundPool(matches(string({soundPool.name}'), SoundSelect));
manyStdSounds = soundPool(matches(string({soundPool.name}'), SoundRand));

%% Std-Dev
% S1-S2
soundSeq = repmat([repmat(selectSounds(1), stdNum, 1); selectSounds(2)], nTrials, 1);
sounds(1) = merge_External_Sequence(soundSeq, "Seq_Tag", "S1_S2", "ISI", ISI, "fs", fs);

% S2-S1
soundSeq = repmat([repmat(selectSounds(2), stdNum, 1); selectSounds(1)], nTrials, 1);
sounds(2) = merge_External_Sequence(soundSeq, "Seq_Tag", "S2_S1", "ISI", ISI, "fs", fs);

%% manyStd-Dev
if length(manyStdSounds) ~= (stdNum+1)
    error("the number of standard sounds is wrong!!!");
end
idx = randperm(length(manyStdSounds), length(manyStdSounds))';

% Rand-S2
soundSeq = repmat(manyStdSounds(idx), nTrials, 1);
sounds(3) = merge_External_Sequence(soundSeq, "Seq_Tag", "ManyStd_S2", "ISI", ISI, "fs", fs);


%% randStd-Dev
% Rand
randSounds = repmat(selectSounds(1), stdNum, 1);
for rIndex = 1 : length(randSounds)
    randSounds(rIndex).name = ['Rand_4ms_Dur300ms_Ver', num2str(rIndex), '.wav'];
    randSounds(rIndex).changeHighIdx = randSounds(rIndex).changeHighIdx(randperm(length(randSounds(rIndex).changeHighIdx)));
    randSounds(rIndex).toHighIdx = [0; randSounds(rIndex).changeHighIdx] + 1;
    randSounds(rIndex).y1 = ICISeq2ClickTrain(randSounds(rIndex).changeHighIdx, 0.2, randSounds(rIndex).fs, max(unique(randSounds(rIndex).y1)));
end

% Rand-S2
soundSeq = [randSounds; selectSounds(2)];
sounds(4) = merge_External_Sequence(soundSeq, "Seq_Tag", "Rand_S2", "ISI", ISI, "fs", fs);

% Rand-S1
soundSeq = [randSounds; selectSounds(1)];
sounds(5) = merge_External_Sequence(soundSeq, "Seq_Tag", "Rand_S1", "ISI", ISI, "fs", fs);

%% export
mkdir(rootPath);
for sIndex = 1 : length(sounds)
    audiowrite(strcat(rootPath, "\Reg_", sounds(sIndex).Tag, ".wav"), sounds(sIndex).Wave, sounds(sIndex).fs);
end
save(fullfile(rootPath, "sounds.mat"), "sounds");
end
