%% check click train
soundPath = "I:\DATA_202303_MonkeyECOG_ClickTrain_TimeIntinSynchron\monkeySounds\2023-03-25_MLA_Oscillation_ICI3-15-22.5-76.1_ratio_1.2_dur_200";
soundParse = clickTrainCheckFcn(soundPath);
temp = soundParse(4);
soundT = (1 : length(temp.y1)) / temp.fs * 1000;
soundY = temp.y1;

% resmpY = resample(soundY, 1000, ceil(temp.fs));
% resmpT = resample(gpuArray(soundT), 1000, ceil(temp.fs));
% resmpYSmth = smoothdata(resmpY, "gaussian", 100);
plot(soundT, soundY);
% scaleAxes(gcf, "x", [0 500]);