clc; clear;

%% Temporal Binding: Basic + BaseICI
Amp = 0.5;
singleDuration = 2000;
s2CutOff = [];
ICIBase = [4, 8, 16];
ratio = 1.015;
repNs = [0, 2];
folderName = "MLA_Basic_4_8_16_Rep";

for rIndex = 1 : length(repNs)
    repN = repNs(rIndex);
    run("generateClickTrain_MonkeyECoG_Basic.m");
end

%% Temporal Binding: Ratio
Amp = 0.5;
singleDuration = 2000;
s2CutOff = [];
ICIBase = 4;
ratio = [1, 1.0025, 1.005, 1.0075, 1.01];
repN = 0;
folderName = "MLA_Basic_4_4o04_Ratio";

run("generateClickTrain_MonkeyECoG_Ratio.m");

%% Temporal Binding: Oscillation
folderName = "MLA_Basic_Oscillation";
Amp = 0.5;
ICIBase = 4;
ratio = 1.015;
successiveDuration = 8000; % ms

singleDuration = 30;
run("generateSuccessiveClickTrain_MonkeyECoG.m");
singleDuration = 60;
run("generateSuccessiveClickTrain_MonkeyECoG.m");
singleDuration = 125;
run("generateSuccessiveClickTrain_MonkeyECoG.m");
singleDuration = 250;
run("generateSuccessiveClickTrain_MonkeyECoG.m");
singleDuration = 500;
run("generateSuccessiveClickTrain_MonkeyECoG.m");

%% Temporal Binding: Variance
Amp = 0.5;
singleDuration = 2000; % ms
s2CutOff = []; % if empty, do not cut
ICIBase = 4;
ratio = 1.015;
sigma = [400, 200, 100, 50]; % ms
folderName = "MLA_Basic_Var";

run("generateClickTrain_MonkeyECoG_Var.m");

%% Temporal Binding: Tone1_Tone2
Amp = 1;
f1 = [250,      250];
f2 = [246.3054, 200];
toneLength = 2000; % ms
cutLength = 4000; % ms
folderName = "MLA_Basic_Tone";

run("generateTone_MonkeyECOG.m");

%% Temporal Binding: Tone Oscillation
Amp = 1;
toneLength = 60; % ms
singleLength = 8000; % ms
cutLength = 8000; % ms
a=ones(1,26); a(2:end)=1.2; 
f1 = round(cumprod(a) * 200);
f2 = f1*1.2;
folderName = "MLA_Tone_Oscillation";

run("generateSuccessiveTone_MonkeyECoG.m");

toneLength = 30; % ms
run("generateSuccessiveTone_MonkeyECoG.m");

%% Offset: 3s 2, 4, 8, 16, 32, 64, 128, Offset
Amp = 0.5;
decodeDuration = 4000; % ms
decodeICI = [1, 2, 4, 8, 16, 32, 64, 128];
folderName = "MLA_Offset_Reg";

run("generateClickTrain_MonkeyECoG_Offset_Reg.m");

decodeDuration = 1000; % ms
run("generateClickTrain_MonkeyECoG_Offset_Reg.m");

%% Offset: 10s 256 512, Offset
Amp = 0.5;
decodeDuration = 10000; % ms
decodeICI = [256, 512];
folderName = "MLA_Offset_Reg";

run("generateClickTrain_MonkeyECoG_Offset_Reg.m");


%% Offset: 4ms ICI Reg: 500, 750, 1s, 2s
Amp = 0.5;
decodeICI = [4, 16];
decodeDurations = [2000, 1000, 750, 500];
folderName = "MLA_Offset_4_16_DiffDur";

for dIndex = 1 : length(decodeDurations)
    decodeDuration = decodeDurations(dIndex);
    run("generateClickTrain_MonkeyECoG_Offset_DiffDur.m");
end


%% Offset: 16ms ICI Irreg: 250, 50, 10, 2
Amp = 0.5;
decodeICI = [4, 16];
sigmas = [250, 50, 10, 2]; % ms
folderName = "MLA_Offset_4_16_DiffVar";
decodeDuration = 2000;

for dIndex = 1 : length(sigmas)
    sigma = sigmas(dIndex);
    run("generateClickTrain_MonkeyECoG_Offset_DiffVar.m");
end

%% TITS
Amp = 0.5;
singleDuration = 3000;
s2CutOff = 2000;
ICIBase = [24 26.4];
ratio = [1, 1.1, 5/3];
folderName = "MLA_TITS_40_24_26o4";

run("generateClickTrain_MonkeyECoG_TITS.m");

%% Temporal Binding: Control 8s 4-4
Amp = 0.5;
singleDuration = 4000;
s2CutOff = [];
ICIBase = 4;
ratio = 1;
repNs = 0;
folderName = "MLA_Basic_4-4_Control";

for rIndex = 1 : length(repNs)
    repN = repNs(rIndex);
    run("generateClickTrain_MonkeyECoG_Basic.m");
end
