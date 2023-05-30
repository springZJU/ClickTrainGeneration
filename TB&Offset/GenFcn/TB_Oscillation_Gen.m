function sounds = TB_Oscillation_Gen(TBOffsetParams)
parseStruct(TBOffsetParams);
%% validate inputs
if ~isequal(S1Dur, S2Dur)
    disp("S1Dur does not equal S2Dur, reset S2Dur to S1Dur");
    S2Dur = S1Dur;
end
if ~isequal(numel(ratio), 1)
    error("ratio should be 1*1 !!!");
end
if ~isequal(numel(ICIBase), 1)
    error("ICIBase should be 1*1 !!!");
end
if ~isequal(numel(SuccessiveDuration), 1)
    error("SuccessiveDuration should be 1*1 !!!");
end

%%
for dIndex = 1 : length(S1Dur)
    clearvars -except TBOffsetParams dIndex S1Dur sounds irregICISampNBase
    Dur = S1Dur(dIndex);
    parseStruct(TBOffsetParams);
    rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));


    %     sounds(dIndex).Info = strcat("Oscillation_Dur", string(S1Dur(dIndex)), "ms");

    %% Generate Click Trains
    ICI1 = repmat(ICIBase, round(SuccessiveDuration/2/Dur), 1);
    ICI2 = ICI1*ratio;

    if contains(soundType, ["Reg&Irreg", "Reg"]) % for regualr
        % generate Reg S1-S2
        Std =RegClickGen(ICI1, Dur, Amp, "fs", fs);
        Dev =RegClickGen(ICI2, Dur, Amp, "fs", fs);
        sounds(dIndex) = merge_Oscillation("Seq_Tag", "S1_S2", "Std_Wave", Std, "Dev_Wave", Dev, "soundType", "Reg");
        sounds(dIndex).Name = strcat(sounds(dIndex).Name, "_Dur-", num2str(Dur), "ms.wav");
    end
end


%% Export sounds
mkdir(rootPath);
for sIndex = 1 : length(sounds)
    soundName = strcat(rootPath, "\", sounds(sIndex).Name);
    audiowrite(soundName, sounds(sIndex).Wave, fs);
end

if saveMat
    save(fullfile(rootPath, "sounds.mat"), "sounds");
end

end