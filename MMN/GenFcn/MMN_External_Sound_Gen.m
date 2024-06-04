function sounds = MMN_External_Sound_Gen(MSTIParams)

parseStruct(MSTIParams);
%% save folder
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

%% validate parameters
% sequence setting
soundPool = clickTrainCheckFcn(SoundPath);
selectSounds = cell2mat(cellfun(@(x) soundPool(matches({soundPool.name}',x)), SoundSelect, "uni", false));
manyStdSounds = soundPool(matches(string({soundPool.name}'), SoundRand));
for dIndex = 1 : length(selectSounds)
%% Std-Dev
% S1-S2
soundSeq = [repmat(selectSounds(1), stdNum, 1); selectSounds(dIndex)];
sounds(1) = merge_External_Sequence(soundSeq, "Seq_Tag", strcat("STD_D", num2str(dIndex-1)), "ISI", ISI, "fs", fs, "successive", successive);

% S2-S1
soundSeq = [repmat(selectSounds(dIndex), stdNum, 1); selectSounds(1)];
sounds(2) = merge_External_Sequence(soundSeq, "Seq_Tag", strcat("D", num2str(dIndex-1), "_STD"), "ISI", ISI, "fs", fs, "successive", successive);

if ManyStd_Rand
    if ManyStd_RandIdx == 0
        randIdx = 1 : stdNum;
    else
        randIdx = ManyStd_RandIdx;
    end
    %% manyStd-Dev
    if stdNum > length(manyStdSounds)
        ncycles = floor(stdNum / length(manyStdSounds));
        idx = [repmat(1:length(manyStdSounds), 1, ncycles), randperm(length(manyStdSounds), stdNum-ncycles * length(manyStdSounds))]';
        idx = idx(randperm(length(idx)));
    else
        idx = randperm(length(manyStdSounds), stdNum-length(manyStdSounds))';
    end

    % Rand-S2
    soundSeq = [repmat(selectSounds(1), randIdx(1)-1, 1); manyStdSounds(idx(randIdx));  repmat(selectSounds(1), stdNum-randIdx(end), 1); selectSounds(dIndex)];
    sounds(3) = merge_External_Sequence(soundSeq, "Seq_Tag", strcat("ManyStd_D", num2str(dIndex-1), "_RandIdx", strjoin(string(randIdx), "-")), "ISI", ISI, "fs", fs, "successive", successive);

    % Rand-S1
    soundSeq = [repmat(selectSounds(dIndex), randIdx(1)-1, 1); manyStdSounds(idx(randIdx));  repmat(selectSounds(dIndex), stdNum-randIdx(end), 1); selectSounds(1)];
    sounds(4) = merge_External_Sequence(soundSeq, "Seq_Tag", strcat("D", num2str(dIndex-1), "_ManyStd", "_RandIdx", strjoin(string(randIdx), "-")), "ISI", ISI, "fs", fs, "successive", successive);

    %% randStd-Dev
    % Rand
    randSounds = repmat(selectSounds(1), stdNum, 1);
    for rIndex = 1 : length(randSounds)
        randSounds(rIndex).name = ['Rand_4ms_Dur300ms_Var', num2str(rIndex), '.wav'];
        randSounds(rIndex).changeHighIdx = randSounds(rIndex).changeHighIdx(randperm(length(randSounds(rIndex).changeHighIdx)));
        randSounds(rIndex).toHighIdx = [0; randSounds(rIndex).changeHighIdx] + 1;
        randSounds(rIndex).y1 = ICISeq2ClickTrain(randSounds(rIndex).changeHighIdx, 0.2, randSounds(rIndex).fs, max(unique(randSounds(rIndex).y1)));
    end

    % Rand-S2
    soundSeq = [repmat(selectSounds(1), randIdx(1)-1, 1); randSounds(idx(randIdx));  repmat(selectSounds(1), stdNum-randIdx(end), 1); selectSounds(dIndex)];
    sounds(5) = merge_External_Sequence(soundSeq, "Seq_Tag", strcat("Rand_D", num2str(dIndex-1), "_RandIdx", strjoin(string(randIdx), "-")), "ISI", ISI, "fs", fs, "successive", successive);

    % Rand-S1
    soundSeq = [repmat(selectSounds(dIndex), randIdx(1)-1, 1); randSounds(idx(randIdx));  repmat(selectSounds(dIndex), stdNum-randIdx(end), 1); selectSounds(1)];
    sounds(6) = merge_External_Sequence(soundSeq, "Seq_Tag", strcat("D", num2str(dIndex-1), "_Rand", "_RandIdx", strjoin(string(randIdx), "-")), "ISI", ISI, "fs", fs, "successive", successive);
end
%% export
mkdir(rootPath);
for sIndex = 1 : length(sounds)
    audiowrite(strcat(rootPath, "\", strcat(sounds(sIndex).Tag, "_", SoundSelect(dIndex))), sounds(sIndex).Wave, sounds(sIndex).fs);
end
end
save(fullfile(rootPath, "sounds.mat"), "sounds");

end
