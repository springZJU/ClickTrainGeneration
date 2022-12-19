clc; clear;

%% Offset: 512ms 4 as control 
Amp = 0.5;
decodeDuration = 512; % ms
decodeICI = 4;
folderName = "MLA_Offset_Reg_Control";

run("generateClickTrain_RatLinearArray_Offset_Reg.m");

decodeICI = 8;
run("generateClickTrain_RatLinearArray_Offset_Reg.m");

%% Offset: 4ms ICI Reg: 4-512
Amp = 0.5;
decodeICI = 4;
decodeDurations = [4, 8, 16, 32, 64, 128, 256, 512, 1024];
folderName = "MLA_Offset_4_DiffDur_Gen";

for dIndex = 1 : length(decodeDurations)
    decodeDuration = decodeDurations(dIndex);
    run("generateClickTrain_RatLinearArray_Offset_DiffDur_Gen.m");
end

%% Offset: 8ms ICI Reg: 4-512
Amp = 0.5;
decodeICI = 8;
decodeDurations = [8, 16, 32, 64, 128, 256, 512, 1024];
folderName = "MLA_Offset_8_DiffDur_Gen";

for dIndex = 1 : length(decodeDurations)
    decodeDuration = decodeDurations(dIndex);
    run("generateClickTrain_RatLinearArray_Offset_DiffDur_Gen.m");
end

%% Offset: 10s 256 512, Offset
Amp = 0.5;
decodeDuration = 10000; % ms
decodeICI = [256, 512];
folderName = "MLA_Offset_Reg";

run("generateClickTrain_RatLinearArray_Offset_Reg.m");

%% Offset: 4ms ICI Irreg: 250, 50, 10, 2
Amp = 0.5;
decodeICI = 4;
sigmas = [100, 50, 25, 10, 2]; % ms
folderName = "MLA_Offset_4_DiffVar_512ms";
decodeDuration = 512;

for dIndex = 1 : length(sigmas)
    sigma = sigmas(dIndex);
    run("generateClickTrain_RatLinearArray_Offset_DiffVar.m");
end

%% Offset: 8ms ICI Irreg: 250, 50, 10, 2
Amp = 0.5;
decodeICI = 8;
sigmas = [100, 50, 25, 10, 2]; % ms
folderName = "MLA_Offset_8_DiffVar_512ms";
decodeDuration = 512;

for dIndex = 1 : length(sigmas)
    sigma = sigmas(dIndex);
    run("generateClickTrain_RatLinearArray_Offset_DiffVar.m");
end

