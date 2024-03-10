function RegMMNSequence = FreqTemp_Toneburst_Gen_V3(clickTrainParams)
parseStruct(clickTrainParams);
%% validate parameters
% Freq setting
eval(Freq_Apply);

%% save folder
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

%% generate single Reg
FreqPool1 = FreqPool; FreqPool2 = roundn(FreqPool1 * FreqDevratio, -1); FreqPool3 = roundn(FreqPool1 / FreqDevratio, -1);
ITI1 = ITI; ITI2 = roundn(ITI1 * ITIDevratio, -1); ITI3 = roundn(ITI1 / ITIDevratio, -1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% target stimulation
Freq1Temp1_Single_RegWave = mRegClickGen(ITI1, TrainDur, Amp, "freqpool", FreqPool1);
Freq1Temp2_Single_RegWave = mRegClickGen(ITI2, TrainDur, Amp, "freqpool", FreqPool1);
Freq2Temp1_Single_RegWave = mRegClickGen(ITI1, TrainDur, Amp, "freqpool", FreqPool2);
% others for ManyStd
Freq1Temp3_Single_RegWave = mRegClickGen(ITI3, TrainDur, Amp, "freqpool", FreqPool1);
Freq2Temp2_Single_RegWave = mRegClickGen(ITI2, TrainDur, Amp, "freqpool", FreqPool2);
Freq2Temp3_Single_RegWave = mRegClickGen(ITI3, TrainDur, Amp, "freqpool", FreqPool2);
Freq3Temp1_Single_RegWave = mRegClickGen(ITI1, TrainDur, Amp, "freqpool", FreqPool3);
Freq3Temp2_Single_RegWave = mRegClickGen(ITI2, TrainDur, Amp, "freqpool", FreqPool3);
Freq3Temp3_Single_RegWave = mRegClickGen(ITI3, TrainDur, Amp, "freqpool", FreqPool3);
% add soundtype
Freq1Temp1_Single_RegWave = addfield(Freq1Temp1_Single_RegWave, 'SoundOrdr', 1);Freq1Temp1_Single_RegWave = addfield(Freq1Temp1_Single_RegWave, 'SoundType', ["Fr1Tp1"]);
Freq1Temp2_Single_RegWave = addfield(Freq1Temp2_Single_RegWave, 'SoundOrdr', 2);Freq1Temp2_Single_RegWave = addfield(Freq1Temp2_Single_RegWave, 'SoundType', ["Fr1Tp2"]);
Freq2Temp1_Single_RegWave = addfield(Freq2Temp1_Single_RegWave, 'SoundOrdr', 3);Freq2Temp1_Single_RegWave = addfield(Freq2Temp1_Single_RegWave, 'SoundType', ["Fr2Tp1"]);
Freq1Temp3_Single_RegWave = addfield(Freq1Temp3_Single_RegWave, 'SoundOrdr', 4);Freq1Temp3_Single_RegWave = addfield(Freq1Temp3_Single_RegWave, 'SoundType', ["ManyStd1"]);
Freq2Temp2_Single_RegWave = addfield(Freq2Temp2_Single_RegWave, 'SoundOrdr', 5);Freq2Temp2_Single_RegWave = addfield(Freq2Temp2_Single_RegWave, 'SoundType', ["ManyStd2"]);
Freq2Temp3_Single_RegWave = addfield(Freq2Temp3_Single_RegWave, 'SoundOrdr', 6);Freq2Temp3_Single_RegWave = addfield(Freq2Temp3_Single_RegWave, 'SoundType', ["ManyStd3"]);
Freq3Temp1_Single_RegWave = addfield(Freq3Temp1_Single_RegWave, 'SoundOrdr', 7);Freq3Temp1_Single_RegWave = addfield(Freq3Temp1_Single_RegWave, 'SoundType', ["ManyStd4"]);
Freq3Temp2_Single_RegWave = addfield(Freq3Temp2_Single_RegWave, 'SoundOrdr', 8);Freq3Temp2_Single_RegWave = addfield(Freq3Temp2_Single_RegWave, 'SoundType', ["ManyStd5"]);
Freq3Temp3_Single_RegWave = addfield(Freq3Temp3_Single_RegWave, 'SoundOrdr', 9);Freq3Temp3_Single_RegWave = addfield(Freq3Temp3_Single_RegWave, 'SoundType', ["ManyStd6"]);
ManyStdSeq_StdComponents_RegWave = [Freq1Temp3_Single_RegWave, Freq2Temp2_Single_RegWave, Freq2Temp3_Single_RegWave, Freq3Temp1_Single_RegWave, Freq3Temp2_Single_RegWave, Freq3Temp3_Single_RegWave];
ManyStdSeq_DevComponents_RegWave = [Freq1Temp1_Single_RegWave, Freq1Temp2_Single_RegWave, Freq2Temp1_Single_RegWave];
AllComponents_RegWave = [ManyStdSeq_DevComponents_RegWave, ManyStdSeq_StdComponents_RegWave];
% merge
RegMMNSequence(1) = merge_FreqTemp_ContinueSequence("Seq_Tag", "Type1StdFq1Tp1_DevFq1Tp2", "Std_Wave", Freq1Temp1_Single_RegWave, "Dev_Wave", Freq1Temp2_Single_RegWave, ...
    "clickType", "toneBurst", "ISI", ISI, "StdNum", stdNum, "DevNum", 1, "RepNum", RepNum);
RegMMNSequence(2) = merge_FreqTemp_ContinueSequence("Seq_Tag", "Type2StdFq1Tp2_DevFq1Tp1", "Std_Wave", Freq1Temp2_Single_RegWave, "Dev_Wave", Freq1Temp1_Single_RegWave, ...
    "clickType", "toneBurst", "ISI", ISI, "StdNum", stdNum, "DevNum", 1, "RepNum", RepNum);
RegMMNSequence(3) = merge_FreqTemp_ContinueSequence("Seq_Tag", "Type3StdFq1Tp1_DevFq2Tp1", "Std_Wave", Freq1Temp1_Single_RegWave, "Dev_Wave", Freq2Temp1_Single_RegWave, ...
    "clickType", "toneBurst", "ISI", ISI, "StdNum", stdNum, "DevNum", 1, "RepNum", RepNum);
RegMMNSequence(4) = merge_FreqTemp_ContinueSequence("Seq_Tag", "Type4StdFq2Tp1_DevFq1Tp1", "Std_Wave", Freq2Temp1_Single_RegWave, "Dev_Wave", Freq1Temp1_Single_RegWave, ...
    "clickType", "toneBurst", "ISI", ISI, "StdNum", stdNum, "DevNum", 1, "RepNum", RepNum);
RegMMNSequence(5) = merge_FreqTemp_ContinueSequence("Seq_Tag", "Type5ManyStd", "Std_Wave", ManyStdSeq_StdComponents_RegWave, "Dev_Wave", ManyStdSeq_DevComponents_RegWave, ...
    "clickType", "toneBurst", "ISI", ISI, "StdNum", numel(ManyStdSeq_StdComponents_RegWave), "DevNum", numel(ManyStdSeq_DevComponents_RegWave), "RepNum", RepNum);
%% export sound wave
mkdir(rootPath);
for sIndex = 1 : length(AllComponents_RegWave)
    FreqComponents = strrep(join(string(AllComponents_RegWave(sIndex).freqpool([1, end])/1000), "-"), ".", "o");
    soundName = strcat(num2str(AllComponents_RegWave(sIndex).SoundOrdr), "_", AllComponents_RegWave(sIndex).SoundType, ...
        "_Fr", FreqComponents, "k_ITI", num2str(AllComponents_RegWave(sIndex).ITIs), "ms.wav");
    audiowrite(strcat(rootPath, "\", soundName), AllComponents_RegWave(sIndex).Wave, AllComponents_RegWave(sIndex).fs);
end
save(fullfile(rootPath, "MMNSequence.mat"), "RegMMNSequence");
%% export order
for blockIdx = 1 : numel(RegMMNSequence)
    params.(strrep(RegMMNSequence(blockIdx).Tag, "_", "")) = [RegMMNSequence(blockIdx).SeqStruct.SoundOrdr];
    generateParamsFiles(char(strcat(rootPath, "\")), params);
end
%% check wave
checkChoice = evalin("base", "checkChoice");
checkNums = 1:9;
rowNum = numel(checkNums);
colNum = 3; % col1:raw wave | col2:fft | col3:cwt
if checkChoice
    Fig = figure;
    maximizeFig(Fig);
    for soundIdx = 1 : numel(AllComponents_RegWave)
        Temp = AllComponents_RegWave(checkNums(soundIdx));
        Soundfreqpool = Temp.freqpool;
        titleStr = strcat(Temp.SoundType, "-Fr", join(string(Soundfreqpool), "-"), "k-ITI", num2str(Temp.ITIs), "ms");
        t = [1/fs : 1/fs : numel(Temp.Wave)/fs] * 1000;

        subplot(rowNum, colNum, 1 + (soundIdx - 1) * colNum);% single click wave
        plot(t, Temp.Wave); xlim([0, 2 * Temp.ITIs]);
        title(titleStr);
    
        subplot(rowNum, colNum, 2 + (soundIdx - 1) * colNum);% fft 
        [fftAmp, freq, ~, ~] = mfft(Temp.Wave, Temp.fs);
        plot(freq, fftAmp);hold on;lines = [];
        for freqIdx = 1 : numel(Soundfreqpool)
            lines(freqIdx).X = Soundfreqpool(freqIdx);
        end
        addLines2Axes(gca, lines);hold off;

        subplot(rowNum, colNum, 3 + (soundIdx - 1) * colNum);% cwt
        [wt, f] = cwt(Temp.Wave, 'morse', Temp.fs);
        [freq,~,~] = engunits(f,'unicode');
        imagesc(t / 1000, freq, abs(wt));
        set(gca, "YScale", "log");axis xy;
        xlim([0, TrainDur/1000]); ylim([min(Soundfreqpool/1000), max(Soundfreqpool/1000) + 2]);
        yticks([0, 2.^(0:nextpow2(max(freq)) - 1)]);
        xlabel('Time(s)');ylabel('Frequence(kHz)');  
    end
    mkdir(rootPath);
    print(gcf, fullfile(rootPath, "SoundCheck"), '-djpeg', '-r200');
end

end
