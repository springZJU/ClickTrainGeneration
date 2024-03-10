function RegMMNSequence = FreqTemp_Toneburst_Gen_V2(clickTrainParams)
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
Freq1Temp1_Single_RegWave = addfield(Freq1Temp1_Single_RegWave, 'SoundType', ["Fr1Tp1"]);
Freq1Temp2_Single_RegWave = addfield(Freq1Temp2_Single_RegWave, 'SoundType', ["Fr1Tp2"]);
Freq2Temp1_Single_RegWave = addfield(Freq2Temp1_Single_RegWave, 'SoundType', ["Fr2Tp1"]);
Freq1Temp3_Single_RegWave = addfield(Freq1Temp3_Single_RegWave, 'SoundType', ["ManyStd1"]);
Freq2Temp2_Single_RegWave = addfield(Freq2Temp2_Single_RegWave, 'SoundType', ["ManyStd2"]);
Freq2Temp3_Single_RegWave = addfield(Freq2Temp3_Single_RegWave, 'SoundType', ["ManyStd3"]);
Freq3Temp1_Single_RegWave = addfield(Freq3Temp1_Single_RegWave, 'SoundType', ["ManyStd4"]);
Freq3Temp2_Single_RegWave = addfield(Freq3Temp2_Single_RegWave, 'SoundType', ["ManyStd5"]);
Freq3Temp3_Single_RegWave = addfield(Freq3Temp3_Single_RegWave, 'SoundType', ["ManyStd6"]);
ManyStdSeq_StdComponents_RegWave = [Freq1Temp3_Single_RegWave, Freq2Temp2_Single_RegWave, Freq2Temp3_Single_RegWave, Freq3Temp1_Single_RegWave, Freq3Temp2_Single_RegWave, Freq3Temp3_Single_RegWave];
ManyStdSeq_DevComponents_RegWave = [Freq1Temp1_Single_RegWave, Freq1Temp2_Single_RegWave, Freq2Temp1_Single_RegWave];
% merge
RegMMNSequence(1) = merge_FreqTemp_ContinueSequence("Seq_Tag", "01StdFq1Tp1_DevFq1Tp2", "Std_Wave", Freq1Temp1_Single_RegWave, "Dev_Wave", Freq1Temp2_Single_RegWave, ...
    "clickType", "toneBurst", "ISI", ISI, "StdNum", stdNum, "DevNum", 1, "RepNum", RepNum);
RegMMNSequence(2) = merge_FreqTemp_ContinueSequence("Seq_Tag", "02StdFq1Tp2_DevFq1Tp1", "Std_Wave", Freq1Temp2_Single_RegWave, "Dev_Wave", Freq1Temp1_Single_RegWave, ...
    "clickType", "toneBurst", "ISI", ISI, "StdNum", stdNum, "DevNum", 1, "RepNum", RepNum);
RegMMNSequence(3) = merge_FreqTemp_ContinueSequence("Seq_Tag", "03StdFq1Tp1_DevFq2Tp1", "Std_Wave", Freq1Temp1_Single_RegWave, "Dev_Wave", Freq2Temp1_Single_RegWave, ...
    "clickType", "toneBurst", "ISI", ISI, "StdNum", stdNum, "DevNum", 1, "RepNum", RepNum);
RegMMNSequence(4) = merge_FreqTemp_ContinueSequence("Seq_Tag", "04StdFq2Tp1_DevFq1Tp1", "Std_Wave", Freq2Temp1_Single_RegWave, "Dev_Wave", Freq1Temp1_Single_RegWave, ...
    "clickType", "toneBurst", "ISI", ISI, "StdNum", stdNum, "DevNum", 1, "RepNum", RepNum);
RegMMNSequence(5) = merge_FreqTemp_ContinueSequence("Seq_Tag", "05ManyStd", "Std_Wave", ManyStdSeq_StdComponents_RegWave, "Dev_Wave", ManyStdSeq_DevComponents_RegWave, ...
    "clickType", "toneBurst", "ISI", ISI, "StdNum", numel(ManyStdSeq_StdComponents_RegWave), "DevNum", numel(ManyStdSeq_DevComponents_RegWave), "RepNum", RepNum);

% check wave
checkChoice = evalin("base", "checkChoice");
checkNums = 1:4;
if checkChoice
    Fig = figure;
    maximizeFig(Fig);
    for soundIdx = 1 : numel(checkNums)
        Temp = RegMMNSequence(checkNums(soundIdx));
        if ~contains(Temp.Name, "ManyStd")
            if contains(regexpi(Temp.Name, 'StdFq\dTp\d', 'match'), "Fq1")
                Soundfreqpool = FreqPool1;
            elseif contains(regexpi(Temp.Name, 'StdFq\dTp\d', 'match'), "Fq2")
                Soundfreqpool = FreqPool2;
            elseif contains(regexpi(Temp.Name, 'StdFq\dTp\d', 'match'), "Fq3")
                Soundfreqpool = FreqPool3;
            end
        else
            Soundfreqpool = unique([FreqPool1, FreqPool2, FreqPool3]);
        end
        titleStr = strrep(string(regexpi(Temp.Name, '(.*?)_ISI', 'tokens')), "_", "-");
        t = [1/fs : 1/fs : numel(Temp.Wave)/fs] * 1000;
        StdITI = double(string(regexpi(Temp.Name, 'StdITI(\d*\.?\d+)', 'tokens')));
        DevITI = double(string(regexpi(Temp.Name, 'DevITI(\d*\.?\d+)', 'tokens')));
        subplot(numel(checkNums), 4, 1 + (soundIdx - 1) * 4);% std single click wave
        plot(t, Temp.Wave); xlim(Temp.StdDev_OnsetSeq(find(Temp.ITISeq == StdITI, 1)) + [0, 2 * max([ITI1, ITI2, ITI3])]);
        title(titleStr);

        subplot(numel(checkNums), 4, 2 + (soundIdx - 1) * 4);% dev single click wave
        plot(t, Temp.Wave); xlim(Temp.StdDev_OnsetSeq(find(Temp.ITISeq == DevITI, 1)) + [0, 2 * max([ITI1, ITI2, ITI3])]);
    
        subplot(numel(checkNums), 4, 3 + (soundIdx - 1) * 4);% fft 
        [fftAmp, freq, ~, ~] = mfft(Temp.Wave, Temp.fs);
        plot(freq, fftAmp);hold on;lines = [];
        for freqIdx = 1 : numel(Soundfreqpool)
            lines(freqIdx).X = Soundfreqpool(freqIdx);
        end
        addLines2Axes(gca, lines);hold off;

        subplot(numel(checkNums), 4, 4 + (soundIdx - 1) * 4);% cwt
        [wt, f] = cwt(Temp.Wave(1:ISI/1000*Temp.fs), 'morse', Temp.fs);
        [freq,~,~] = engunits(f,'unicode');
        imagesc(t(1:ISI/1000*Temp.fs) / 1000, freq, abs(wt));
        set(gca, "YScale", "log");axis xy;
        xlim([0, TrainDur/1000]); ylim([min(Soundfreqpool/1000), max(Soundfreqpool/1000) + 2]);
        yticks([0, 2.^(0:nextpow2(max(freq)) - 1)]);
        xlabel('Time(s)');ylabel('Frequence(kHz)');  
    end
    mkdir(rootPath);
    print(gcf, fullfile(rootPath, "SoundCheck"), '-djpeg', '-r200');
end
%% export
mkdir(rootPath);
for sIndex = 1 : length(RegMMNSequence)
    audiowrite(strcat(rootPath, "\Reg_", RegMMNSequence(sIndex).Name), RegMMNSequence(sIndex).Wave, RegMMNSequence(sIndex).fs);
end
save(fullfile(rootPath, "MMNSequence.mat"), "RegMMNSequence");
end
