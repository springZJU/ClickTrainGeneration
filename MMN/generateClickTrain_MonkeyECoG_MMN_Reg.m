clear;
mPath = mfilename("fullpath");
cd(fileparts(mPath));
%% settings

% sequence setting
stdNum = 9;
ISI = 600; % ms
BG_Start_Dur = 1000; % ms
stdDur = 300; % ms
devDur = stdDur;
BG_Epoc_Dur = ISI-stdDur;
maxDur = max([BG_Start_Dur, ISI, devDur]);

% ICI setting
Amp = 0.5;
BG_ICI = 4; % background ICI
ManyStd_ICI = roundn(linspace(4.1, 4.9, stdNum), -2);
ManyStd_ICI = ManyStd_ICI(randperm(length(ManyStd_ICI)));
S1_ICI = BG_ICI * 1.125;
S2_ICI = BG_ICI * 1.25;

% irreg settings
baseICI = 4;
variance = 2;
repHead = [];
repTail = [];

%% save folder
folderName = strcat("MMN_BackGround_", num2str(BG_Start_Dur), "\", num2str(BG_ICI), "ms_ICIs_", strrep(num2str(S1_ICI), ".", "o"), "_", strrep(num2str(S2_ICI), ".", "o"), "_ISI-", num2str(ISI), "_StdDur-", num2str(stdDur), "_BG_Start-", num2str(BG_Start_Dur));
rootPath = fullfile('..\..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

%% generate single Reg

if BG_Start_Dur == 0
    BG_Start_RegWave.Wave = [];
    BG_Start_RegWave.Duration = 0;
else
    BG_Start_RegWave = RegClickGen(BG_ICI, BG_Start_Dur, Amp);
end
BG_Epoc_RegWave = RegClickGen(repmat(BG_ICI, 1, stdNum), BG_Epoc_Dur, Amp);
ManyStd_RegWave = RegClickGen(ManyStd_ICI, stdDur, Amp);
S1_Std_RegWave = RegClickGen(repmat(S1_ICI, 1, stdNum), stdDur, Amp);
S2_Std_RegWave = RegClickGen(repmat(S2_ICI, 1, stdNum), stdDur, Amp);
S1_Dev_RegWave = RegClickGen(S1_ICI, devDur, Amp);
S2_Dev_RegWave = RegClickGen(S2_ICI, devDur, Amp);

%merge
RegMMNSequence(1) = merge_MMN_Sequence("Seq_Tag", "S1_S2", "BG_Start", BG_Start_RegWave, "BG_Epoc", BG_Epoc_RegWave, "Std_Wave", S1_Std_RegWave, "Dev_Wave", S2_Dev_RegWave);
RegMMNSequence(2) = merge_MMN_Sequence("Seq_Tag", "S2_S1", "BG_Start", BG_Start_RegWave, "BG_Epoc", BG_Epoc_RegWave, "Std_Wave", S2_Std_RegWave, "Dev_Wave", S1_Dev_RegWave);
RegMMNSequence(3) = merge_MMN_Sequence("Seq_Tag", "ManyStd_S2", "BG_Start", BG_Start_RegWave, "BG_Epoc", BG_Epoc_RegWave, "Std_Wave", ManyStd_RegWave, "Dev_Wave", S2_Dev_RegWave);
RegMMNSequence(4) = merge_MMN_Sequence("Seq_Tag", "ManyStd_S1", "BG_Start", BG_Start_RegWave, "BG_Epoc", BG_Epoc_RegWave, "Std_Wave", ManyStd_RegWave, "Dev_Wave", S1_Dev_RegWave);

%% export
mkdir(rootPath);
for sIndex = 1 : length(RegMMNSequence)
    audiowrite(strcat(rootPath, "\Reg_", RegMMNSequence(sIndex).Name), RegMMNSequence(sIndex).Wave, RegMMNSequence(sIndex).fs);
end
save(fullfile(rootPath, "MMNSequence.mat"), "RegMMNSequence");
