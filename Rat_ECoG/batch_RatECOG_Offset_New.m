clc; clear;


%% Offset: 4s 2, 4, 8, 16, 32, 64, 128, Offset
Amp = 0.5;
decodeDuration = 4000; % ms
decodeICI = [1, 2, 4, 8, 16, 32, 64, 128];
folderName = "RE_Offset_Reg";
run("generateClickTrain_MonkeyECoG_Offset_Reg.m");

%% Offset: 500ms 8 as control 
Amp = 0.5;
decodeDuration = 500; % ms
decodeICI = 8;
folderName = "RE_Offset_Reg_Control";

run("generateClickTrain_MonkeyECoG_Offset_Reg.m");

%% Offset: 10s 256 512, Offset
Amp = 0.5;
decodeDuration = 10000; % ms
decodeICI = [256, 512];
folderName = "RE_Offset_Reg";
run("generateClickTrain_MonkeyECoG_Offset_Reg.m");

%% Offset: 2ms ICI Reg: 4-512
Amp = 0.5;
decodeICI = 2;
decodeDurations = [4, 8, 16, 32, 64, 128, 256, 500, 512, 1024];
folderName = "RE_Offset_2_DiffDur_Gen";

for dIndex = 1 : length(decodeDurations)
    decodeDuration = decodeDurations(dIndex);
    run("generateClickTrain_MonkeyECoG_Offset_DiffDur_OffsetGeneration.m");
end

%% Offset: 16ms ICI Reg: 4-512
Amp = 0.5;
decodeICI = 16;
decodeDurations = [16, 32, 64, 128, 256, 500, 512, 1024];
folderName = "RE_Offset_16_DiffDur_Gen";

for dIndex = 1 : length(decodeDurations)
    decodeDuration = decodeDurations(dIndex);
    run("generateClickTrain_MonkeyECoG_Offset_DiffDur_OffsetGeneration.m");
end



%% Offset: 2/16ms ICI Irreg: 250, 50, 10, 2
Amp = 0.5;
decodeICI = [2, 16];
sigmas = [250, 50, 10, 2]; % ms
folderName = "RE_Offset_2_16_DiffVar_500ms";
decodeDuration = 500;

for dIndex = 1 : length(sigmas)
    sigma = sigmas(dIndex);
    run("generateClickTrain_MonkeyECoG_Offset_DiffVar.m");
end

