clc; clear;

%% Offset: 500ms 8 as control 
Amp = 0.5;
decodeDuration = 500; % ms
decodeICI = 8;
folderName = "MLA_Offset_Reg_Control";

run("generateClickTrain_MonkeyECoG_Offset_Reg.m");

%% Offset: 4ms ICI Reg: 4-512
Amp = 0.5;
decodeICI = 4;
decodeDurations = [4, 8, 16, 32, 64, 128, 256, 512, 1024];
folderName = "MLA_Offset_4_DiffDur_Gen";

for dIndex = 1 : length(decodeDurations)
    decodeDuration = decodeDurations(dIndex);
    run("generateClickTrain_MonkeyECoG_Offset_DiffDur_OffsetGeneration.m");
end

%% Offset: 8ms ICI Reg: 4-512
Amp = 0.5;
decodeICI = 8;
decodeDurations = [8, 16, 32, 64, 128, 256, 512, 1024];
folderName = "MLA_Offset_8_DiffDur_Gen";

for dIndex = 1 : length(decodeDurations)
    decodeDuration = decodeDurations(dIndex);
    run("generateClickTrain_MonkeyECoG_Offset_DiffDur_OffsetGeneration.m");
end

%% Offset: 16ms ICI Reg: 4-512
Amp = 0.5;
decodeICI = 16;
decodeDurations = [16, 32, 64, 128, 256, 512, 1024];
folderName = "MLA_Offset_16_DiffDur_Gen";

for dIndex = 1 : length(decodeDurations)
    decodeDuration = decodeDurations(dIndex);
    run("generateClickTrain_MonkeyECoG_Offset_DiffDur_OffsetGeneration.m");
end

%% Offset: 10s 256 512, Offset
Amp = 0.5;
decodeDuration = 10000; % ms
decodeICI = [256, 512];
folderName = "MLA_Offset_Reg";

run("generateClickTrain_MonkeyECoG_Offset_Reg.m");

%% Offset: 16ms ICI Irreg: 250, 50, 10, 2
Amp = 0.5;
decodeICI = [4, 8, 16];
sigmas = [100, 50, 25, 10, 2]; % ms
folderName = "MLA_Offset_4_8_16_DiffVar_500ms";
decodeDuration = 512;

for dIndex = 1 : length(sigmas)
    sigma = sigmas(dIndex);
    run("generateClickTrain_MonkeyECoG_Offset_DiffVar.m");
end

