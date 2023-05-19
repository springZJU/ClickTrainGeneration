function RegMMNSequence = MSTIomi_Reg_Gen(MSTIParams)
parseStruct(MSTIParams);
%% validate parameters
% stdNum and ICI seq(if length of ICI > 1)

% sequence setting
% BG_Epoc_Dur = ISI-stdDur;

% ICI setting
ManyStd_Range = ManyStd_Range * scaleFactor;
BG_ICI = BG_Base * scaleFactor; % background ICI
eval(ManyStd_type_Apply);
eval(ManyStd_Apply);

if logical(ManyStd_Rand)
    ManyStd_ICIpool = repmat(ManyStd_ICI,1,100);
    idx = randperm(length(ManyStd_ICIpool));
    ManyStd_ICIRandomSeq = ManyStd_ICIpool(idx);
    findsameICI = diff(ManyStd_ICIRandomSeq);
    [~,sameICI_inseq] = find(findsameICI == 0);
    ManyStd_ICIRandomSeq(sameICI_inseq+1) = [];
    ManyStd_ICI = ManyStd_ICIRandomSeq(1:(2*stdNum-2));
end
S1_ICI = S1_S2_Base(1) * scaleFactor;
S2_ICI = S1_S2_Base(2) * scaleFactor;


%% save folder
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

%% generate single Reg

if BG_Start_Dur == 0
    BG_Start_RegWave.Wave = [];
    BG_Start_RegWave.Duration = 0;
else
    BG_Start_RegWave = RegClickGen(BG_ICI, BG_Start_Dur, Amp, "fs", fs);
end
if BG_End_Dur == 0
    BG_End_RegWave.Wave = [];
    BG_End_RegWave.Duration = 0;
else
    BG_End_RegWave = RegClickGen(BG_ICI, BG_End_Dur, Amp, "fs", fs);
    MS_S1BG_End_RegWave = RegClickGen(S1_ICI, BG_End_Dur, Amp, "fs", fs);
    MS_S2BG_End_RegWave = RegClickGen(S2_ICI, BG_End_Dur, Amp, "fs", fs);
end

% BG_Epoc_RegWave = RegClickGen(repmat(BG_ICI, 1, stdNum), BG_Epoc_Dur, Amp, "fs", fs);
ManyStd_RegWave = RegClickGen(ManyStd_ICI, S1Dur, Amp, "fs", fs);
S1_Std_RegWave = RegClickGen(repmat(S1_ICI, 1, stdNum), S1Dur, Amp, "fs", fs);
S2_Std_RegWave = RegClickGen(repmat(S2_ICI, 1, stdNum), S1Dur, Amp, "fs", fs);
S1_Dev_RegWave = RegClickGen(S1_ICI, S2Dur, Amp, "fs", fs);
S2_Dev_RegWave = RegClickGen(S2_ICI, S2Dur, Amp, "fs", fs);


%merge
RegMMNSequence(1) = merge_MSTIomi_Sequence("Seq_Tag", "S1_S2",...
    "BG_Start", BG_Start_RegWave, "BG_End", BG_End_RegWave,...
    "S1_Wave", S1_Std_RegWave, "S2_Wave", S2_Std_RegWave, "fs", fs);
RegMMNSequence(2) = merge_MSTIomi_Sequence("Seq_Tag", "S2_S1",...
    "BG_Start", BG_Start_RegWave, "BG_End", BG_End_RegWave,...
    "S1_Wave", S2_Std_RegWave, "S2_Wave", S1_Std_RegWave, "fs", fs);
RegMMNSequence(3) = merge_MSTIomi_Sequence("Seq_Tag", "ManyStd_S12",...
    "BG_Start", BG_Start_RegWave, "BG_End", MS_S1BG_End_RegWave,...
    "S1_Wave", ManyStd_RegWave,...
    "S2_Wave", [S1_Dev_RegWave;S2_Dev_RegWave], "fs", fs);
RegMMNSequence(4) = merge_MSTIomi_Sequence("Seq_Tag", "ManyStd_S21",...
    "BG_Start", BG_Start_RegWave, "BG_End", MS_S2BG_End_RegWave,...
    "S1_Wave", ManyStd_RegWave,...
    "S2_Wave", [S2_Dev_RegWave;S1_Dev_RegWave], "fs", fs);

%% export
mkdir(rootPath);
for sIndex = 1 : length(RegMMNSequence)
    audiowrite(strcat(rootPath, "\Reg_", RegMMNSequence(sIndex).Name), RegMMNSequence(sIndex).Wave, RegMMNSequence(sIndex).fs);
end
save(fullfile(rootPath, "MMNSequence.mat"), "RegMMNSequence");
end
