clc; clear;

%% Temporal Binding: Basic + BaseICI
Amp = 0.5;
singleDuration = 3000;
s2CutOff = 1000;
ratio = [1, 1.005, 1.01, 1.015, 1.1, 1.5];
repNs = [0, 2];

ICIBase = [2, 4, 6, 8];
folderName = "Species_Monkey_Basic_2_4_6_8ms";
for rIndex = 1 : length(repNs)
    repN = repNs(rIndex);
    run("generateClickTrain_MonkeyECoG_Basic.m");
end

%% Temporal Binding: Intense Control
Amp = 0.5;
singleDuration = 3000;
s2CutOff = 1000;
ICIBase = [2, 4];
ratio = [1.015, 1.5];
folderName = "Species_Monkey_Tone_Intense";

run("generateClickTrain_MonkeyECoG_Intense.m");
%% Temporal Binding: Duration
Amp = 0.5;
singleDuration = [1000 1000 2000 3000 4000]; % ms
s1CutOff = [{500}, {[]}, {[]}, {[]}, {[]}]; % if empty, do not cut
s2CutOff = [{[]}, {[]}, {1000}, {1000}, {1000}]; % if empty, do not cut
ICIBase = [2, 4, 6, 8];
ratio = [1.015, 1.5];
folderName = "Species_Monkey_Basic_Duration";

run("generateClickTrain_MonkeyECoG_Duration.m");

%% Temporal Binding: Oscillation

Amp = 0.5;
ICIBase = [2, 4, 6, 8];
ratio = [1.015, 1.5];
successiveDuration = 8000; % ms
folderName = "Species_Monkey_Basic_Oscillation";

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


% Oscillation control
Amp = 0.5;
singleDuration = 4000;
s2CutOff = [];
ratio = 1;
repNs = 0;
ICIBase = [2, 4, 6, 8];

folderName = "Species_Monkey_Basic_Oscillation_Control";
for rIndex = 1 : length(repNs)
    repN = repNs(rIndex);
    run("generateClickTrain_MonkeyECoG_Ratio.m");
end

%% Temporal Binding: Variance
Amp = 0.5;
singleDuration = 3000; % ms
s2CutOff = 1000; % if empty, do not cut
ICIBase = [2, 4, 6, 8];
ratio = [1.015, 1.5];
sigma = [200, 100, 50, 25, 10]; % ms
folderName = "Species_Monkey_Basic_Var";

run("generateClickTrain_MonkeyECoG_Var.m");

%% Temporal Binding: Tone1_Tone2
Amp = 1;
f1 = [250,      250, 250,    500,    500,      500];
f2 = [246.3054, 200, 166.67, 333.33, 492.6108, 400];
toneLength = 3000; % ms
cutLength = 4000; % ms
folderName = "Species_Monkey_Basic_Tone";

run("generateTone_MonkeyECOG.m");

%% Temporal Binding: Tone Oscillation
Amp = 1;
toneLength = 60; % ms
singleLength = 8000; % ms
cutLength = 8000; % ms
f1 = [250,      250, 250,    500,    500,      500];
f2 = [246.3054, 200, 166.67, 333.33, 492.6108, 400];
folderName = "Species_Monkey_Tone_Oscillation";

run("generateSuccessiveTone_MonkeyECoG.m");

toneLength = 30; % ms
run("generateSuccessiveTone_MonkeyECoG.m");

