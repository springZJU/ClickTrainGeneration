clc; clear;

%% Temporal Binding: Basic + BaseICI
Amp = 0.5;
singleDuration = 2000;
s2CutOff = 1000;
ICIBase = [2, 4, 8];
ratio = 1.5;
repNs = [0, 2];
folderName = "MLA_Basic_4_8_16_Rep";

for rIndex = 1 : length(repNs) 
    repN = repNs(rIndex);
    run("generateClickTrain_RatLinearArray_Basic.m");
end

%% Temporal Binding: Ratio
Amp = 0.5;
singleDuration = 2000;
s2CutOff = 1000;
ICIBase = 2;
ratio = [1, 1.1, 1.3, 1.5, 1.7];
repN = 0;
folderName = "MLA_Basic_2_3.4_Ratio";

run("generateClickTrain_RatLinearArray_Ratio.m");

%% Temporal Binding: Oscillation
folderName = "MLA_Basic_Oscillation";
Amp = 0.5;
ICIBase = 2;
ratio = 1.5;
successiveDuration = 6000; % ms

singleDuration = 30;
run("generateSuccessiveClickTrain_RatLinearArray.m");
singleDuration = 60;
run("generateSuccessiveClickTrain_RatLinearArray.m");
singleDuration = 125;
run("generateSuccessiveClickTrain_RatLinearArray.m");
singleDuration = 250;
run("generateSuccessiveClickTrain_RatLinearArray.m");
singleDuration = 500;
run("generateSuccessiveClickTrain_RatLinearArray.m");

%% Temporal Binding: Variance
Amp = 0.5;
singleDuration = 2000; % ms
s2CutOff = 1000; % if empty, do not cut
ICIBase = 2;
ratio = 1.5;
sigma = [200, 100, 50, 25, 10]; % ms
folderName = "MLA_Basic_Var";

run("generateClickTrain_RatLinearArray_Var.m");

%% Temporal Binding: Tone1_Tone2
Amp = 1;
f1 = 500;
f2 = 333;
toneLength = 2000; % ms
cutLength = 3000; % ms
folderName = "MLA_Basic_Tone";

run("generateTone_RatLinearArray.m");

%% Temporal Binding: Tone Oscillation
Amp = 1;
toneLength = 60; % ms
singleLength = 6000; % ms
cutLength = 6000; % ms
f1 = logspace(log10(f1), log10(f2), 26);
f2 = f1*1.5;
folderName = "MLA_Tone_Oscillation";

run("generateSuccessiveTone_RatLinearArray.m");

toneLength = 30; % ms
run("generateSuccessiveTone_RatLinearArray.m");

%% Temporal Binding: Control 8s 4-4
Amp = 0.5;
singleDuration = 3000;
s2CutOff = [];
ICIBase = 4;
ratio = 1;
repNs = 0;
folderName = "MLA_Basic_4-4_Control";

for rIndex = 1 : length(repNs)
    repN = repNs(rIndex);
    run("generateClickTrain_RatLinearArray_Basic.m");
end
