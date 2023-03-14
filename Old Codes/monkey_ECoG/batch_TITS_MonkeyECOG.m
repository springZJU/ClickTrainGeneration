% %% 15ms ICI Reg & Irreg : 500, 750, 1s
% clc; clear;
% mPath = mfilename("fullpath");
% cd(fileparts(mPath));
% 
% decodeICI = 15;
% decodeDurations = [1000, 750, 500];
% folderName = "Offset_15_DiffDur";
% for dIndex = 1 : length(decodeDurations)
%     decodeDuration = decodeDurations(dIndex);
%     run("generateClickTrain_MonkeyECoG_Offset_DiffDur.m");
% end
% clear decodeICI decodeDurations irregICISampNBase

%%  Irreg to Reg 3s-4s, reverse
clc; clear;
mPath = mfilename("fullpath");
cd(fileparts(mPath));

decodeICIs = [4, 15, 20, 25];
decodeDuration = 8000; % ms
repDuration = 4000;
singleCutOff = [];
folderName = "Offset_Rep_By_Duration";
for dIndex = 1 : length(decodeICIs)
    decodeICI = decodeICIs(dIndex);
    run("generateClickTrain_MonkeyECoG_Offset_Rep_By_Duration.m");
end
clear decodeICI decodeDurations irregICISampNBase

%% noise + click train
clc; clear;
mPath = mfilename("fullpath");
% cd(fileparts(mPath));

noiseDuration = 4000;
clickDuration = 4000;
decodeICI = 15;
singleCutOff = [3000, 4000];
folderName = "Offset_Noise_Reg";
run("generateClickTrain_MonkeyECoG_Noise_Reg.m");

%% check click train
soundPath = "E:\ratNeuroPixel\monkeySounds\2022-11-15_Offset_Rep_By_Duration\offset";
soundParse = clickTrainCheckFcn(soundPath);
temp = soundParse(1);
soundT = (1 : length(temp.y1)) / temp.fs * 1000;
soundY = temp.y1;

resmpY = resample(soundY, 500, temp.fs);
resmpT = resample(soundT, 500, temp.fs);
resmpYSmth = smoothdata(resmpY, "gaussian", 100);
figure
plot(resmpT, resmpYSmth);

figure
find(soundY > 0);