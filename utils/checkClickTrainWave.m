%% check click train
soundPath = "E:\ratNeuroPixel\monkeySounds\2022-11-25_MLA_Basic_4_8_16_Rep\interval 0";
soundParse = clickTrainCheckFcn(soundPath);
temp = soundParse(9);
soundT = (1 : length(temp.y1)) / temp.fs * 1000;
soundY = temp.y1;

resmpY = resample(soundY, 500, ceil(temp.fs));
resmpT = resample(gpuArray(soundT), 500, ceil(temp.fs));
resmpYSmth = smoothdata(resmpY, "gaussian", 100);
plot(resmpT, resmpYSmth);