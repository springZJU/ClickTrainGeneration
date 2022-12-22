clearvars -except IrregBase;
mPath = mfilename("fullpath");
cd(fileparts(mPath));
%% settings
% sequence setting
stdNum = 9;
ISI = 800; % ms
BG_Start_Dur = 2000; % ms
BG_End_Dur = 1000; % ms
stdDur = 300; % ms
devDur = stdDur;
BG_Epoc_Dur = ISI-stdDur;


% ICI setting
Amp = 0.5;
BG_Base = 5;
scaleFactor = 2;
ManyStd_Range = [4.1, 4.9] * scaleFactor;
S1_S2_Base = [4.5, 4];
BG_ICI = BG_Base * scaleFactor; % background ICI
ManyStd_ICI = roundn(linspace(ManyStd_Range(1), ManyStd_Range(2), stdNum), -2);
ManyStd_ICI = ManyStd_ICI(randperm(length(ManyStd_ICI)));
S1_ICI = S1_S2_Base(1) * scaleFactor;
S2_ICI = S1_S2_Base(2) * scaleFactor;

% irreg settings
baseICI = 4;
variance = 100;
repHead = [];
repTail = [];

%% save folder
folderName = strcat("MMN_BackGround\Irreg_Var-", num2str(variance), "_BG_ICI",num2str(BG_ICI), "ms_ICIs_", strrep(num2str(S1_ICI), ".", "o"), "_", strrep(num2str(S2_ICI), ".", "o"), "_ISI-", num2str(ISI), "_StdDur-", num2str(stdDur), "_BG_Start-", num2str(BG_Start_Dur));
rootPath = fullfile('..\..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

%% generate single Irreg
if BG_Start_Dur == 0
    BG_Start_IrregWave.Wave = [];
    BG_Start_IrregWave.Duration = 0;
else
    BG_Start_IrregWave = RegClickGen(BG_ICI, BG_Start_Dur, Amp);
end

if BG_End_Dur == 0
    BG_End_IrregWave.Wave = [];
    BG_End_IrregWave.Duration = 0;
else
    BG_End_IrregWave = RegClickGen(BG_ICI, BG_End_Dur, Amp);
end

BG_Epoc_IrregWave = RegClickGen(repmat(BG_ICI, 1, stdNum), BG_Epoc_Dur, Amp);
ManyStd_IrregWave = IrregClickGen(ManyStd_ICI, stdDur, Amp, "irregICISampNBase", IrregBase.SampN, "repHead", repHead, "repTail", repTail);
S1_Std_IrregWave = IrregClickGen(repmat(S1_ICI, 1, stdNum), stdDur, Amp, "irregICISampNBase", IrregBase.SampN, "repHead", repHead, "repTail", repTail);
S2_Std_IrregWave = IrregClickGen(repmat(S2_ICI, 1, stdNum), stdDur, Amp, "irregICISampNBase", IrregBase.SampN, "repHead", repHead, "repTail", repTail);
S1_Dev_IrregWave = IrregClickGen(S1_ICI, devDur, Amp, "irregICISampNBase", IrregBase.SampN, "repHead", repHead, "repTail", repTail);
S2_Dev_IrregWave = IrregClickGen(S2_ICI, devDur, Amp, "irregICISampNBase", IrregBase.SampN, "repHead", repHead, "repTail", repTail);

%merge
IrregMMNSequence(1) = merge_MMN_Sequence("Seq_Tag", "S1_S2", "BG_Start", BG_Start_IrregWave, "BG_End", BG_End_IrregWave, "BG_Epoc", BG_Epoc_IrregWave, "Std_Wave", S1_Std_IrregWave, "Dev_Wave", S2_Dev_IrregWave);
IrregMMNSequence(2) = merge_MMN_Sequence("Seq_Tag", "S2_S1", "BG_Start", BG_Start_IrregWave, "BG_End", BG_End_IrregWave, "BG_Epoc", BG_Epoc_IrregWave, "Std_Wave", S2_Std_IrregWave, "Dev_Wave", S1_Dev_IrregWave);
IrregMMNSequence(3) = merge_MMN_Sequence("Seq_Tag", "ManyStd_S2", "BG_Start", BG_Start_IrregWave, "BG_End", BG_End_IrregWave, "BG_Epoc", BG_Epoc_IrregWave, "Std_Wave", ManyStd_IrregWave, "Dev_Wave", S2_Dev_IrregWave);
IrregMMNSequence(4) = merge_MMN_Sequence("Seq_Tag", "ManyStd_S1", "BG_Start", BG_Start_IrregWave, "BG_End", BG_End_IrregWave, "BG_Epoc", BG_Epoc_IrregWave, "Std_Wave", ManyStd_IrregWave, "Dev_Wave", S1_Dev_IrregWave);

%% export
mkdir(rootPath);
for sIndex = 1 : length(IrregMMNSequence)
    audiowrite(strcat(rootPath, "\Irreg_", IrregMMNSequence(sIndex).Name), IrregMMNSequence(sIndex).Wave, IrregMMNSequence(sIndex).fs);
end
save(fullfile(rootPath, "MMNSequence.mat"), "IrregMMNSequence");
