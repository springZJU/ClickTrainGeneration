function RegMMNSequence = MMN_External_Sound_Gen(MSTIParams)

parseStruct(MSTIParams);

%% validate parameters
% sequence setting
sounds = clickTrainCheckFcn(SoundPath);
selectSounds = sounds(matches(string({sounds.name}'), SoundSelect));
randSounds = sounds(matches(string({sounds.name}'), SoundRand));

% S1-S2
soundSeq = [repmat(selectSounds(1), stdNum, 1); selectSounds(2)];
sounds(1) = merge_External_Sequence(soundSeq, "Seq_Tag", "S1_S2", "ISI", ISI, "fs", fs);

% S2-S1
soundSeq = [repmat(selectSounds(2), stdNum, 1); selectSounds(1)];
sounds(2) = merge_External_Sequence(soundSeq, "Seq_Tag", "S2_S1", "ISI", ISI, "fs", fs);

randSounds(randperm(5,7))
% Rand-S2
soundSeq = [randSounds(randperm), stdNum, 1; selectSounds(2)];
sounds(3) = merge_External_Sequence(soundSeq, "Seq_Tag", "ManyStd_S2", "ISI", ISI, "fs", fs);

% Rand-S1
soundSeq = [repmat(selectSounds(1), stdNum, 1); repmat(selectSounds(2), stdNum, 1)];
sounds(4) = merge_External_Sequence(soundSeq, "Seq_Tag", "ManyStd_S1", "ISI", ISI, "fs", fs);

%% export
mkdir(rootPath);
for sIndex = 1 : length(RegMMNSequence)
    audiowrite(strcat(rootPath, "\Reg_", RegMMNSequence(sIndex).Name), RegMMNSequence(sIndex).Wave, RegMMNSequence(sIndex).fs);
end
save(fullfile(rootPath, "MMNSequence.mat"), "RegMMNSequence");
end
