%% check click train
soundPath = "E:\ratNeuroPixel\monkeySounds\2022-11-17_MLA_TITS_40_24_26o4\interval 0";
soundParse = clickTrainCheckFcn(soundPath);
temp = soundParse(6);
soundT = (1 : length(temp.y1)) / temp.fs * 1000;
soundY = temp.y1;

resmpY = resample(soundY, 500, ceil(temp.fs));
resmpT = resample(gpuArray(soundT), 500, ceil(temp.fs));
resmpYSmth = smoothdata(resmpY, "gaussian", 100);
plot(resmpT, resmpYSmth);