clc; clear;
mPath = mfilename("fullpath");
cd(fileparts(mPath));

%% 15ms ICI Reg & Irreg : 250, 500, 1s, 2s, 4s
decodeICI = 12;
decodeDurations = [4000, 2000, 1000, 500, 250];
for dIndex = 1 : length(decodeDurations)
    decodeDuration = decodeDurations(dIndex);
    run("generateClickTrain_RatECoG_Offset_DiffDur.m");
end
clear decodeICI decodeDurations
%% 
decodeICIs = [12,16,24];
decodeDuration = 4000; % ms
repDuration = 2000;
for dIndex = 1 : length(decodeICIs)
    decodeICI = decodeICIs(dIndex);
run("generateClickTrain_RatECoG_Offset_Rep_By_Duration.m");
end

