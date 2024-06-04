function RegMMNSequence = FreqTemp_Toneburst_Gen(clickTrainParams)
parseStruct(clickTrainParams);
%% validate parameters
% Freq setting
eval(Freq_Apply);

%% save folder
rootPath = fullfile("..\..\", ParentFolderName, strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));

%% generate single Reg
Freq1Temp1_StdSeq_RegWave = mRegClickGen(repmat(ITI, 1, stdNum), TrainDur, Amp, "freqpool", FreqPool);
Freq1Temp1_Dev_RegWave = mRegClickGen(ITI, TrainDur, Amp, "freqpool", FreqPool);
Freq1Temp2_StdSeq_RegWave = mRegClickGen(repmat(ITI * ITIDevratio, 1, stdNum), TrainDur, Amp, "freqpool", FreqPool);
Freq1Temp2_Dev_RegWave = mRegClickGen(ITI * ITIDevratio, TrainDur, Amp, "freqpool", FreqPool);

Freq2Temp1_StdSeq_RegWave = mRegClickGen(repmat(ITI, 1, stdNum), TrainDur, Amp, "freqpool", FreqPool * FreqDevratio);
Freq2Temp1_Dev_RegWave = mRegClickGen(ITI, TrainDur, Amp, "freqpool", FreqPool * FreqDevratio);
Freq2Temp2_StdSeq_RegWave = mRegClickGen(repmat(ITI * ITIDevratio, 1, stdNum), TrainDur, Amp, "freqpool", FreqPool * FreqDevratio);
Freq2Temp2_Dev_RegWave = mRegClickGen(ITI * ITIDevratio, TrainDur, Amp, "freqpool", FreqPool * FreqDevratio);

%merge
RegMMNSequence(1) = merge_FreqTemp_Sequence("Seq_Tag", "StdFq1Tp1_DevFq1Tp2", "Std_Wave", Freq1Temp1_StdSeq_RegWave, "Dev_Wave", Freq1Temp2_Dev_RegWave, "clickType", "toneBurst", "ISI", ISI);
RegMMNSequence(2) = merge_FreqTemp_Sequence("Seq_Tag", "StdFq1Tp1_DevFq2Tp1", "Std_Wave", Freq1Temp1_StdSeq_RegWave, "Dev_Wave", Freq2Temp1_Dev_RegWave, "clickType", "toneBurst", "ISI", ISI);
RegMMNSequence(3) = merge_FreqTemp_Sequence("Seq_Tag", "StdFq1Tp2_DevFq1Tp1", "Std_Wave", Freq1Temp2_StdSeq_RegWave, "Dev_Wave", Freq1Temp1_Dev_RegWave, "clickType", "toneBurst", "ISI", ISI);
RegMMNSequence(4) = merge_FreqTemp_Sequence("Seq_Tag", "StdFq2Tp1_DevFq1Tp1", "Std_Wave", Freq2Temp1_StdSeq_RegWave, "Dev_Wave", Freq1Temp1_Dev_RegWave, "clickType", "toneBurst", "ISI", ISI);

% check wave
checkChoice = evalin("base", "checkChoice");
if checkChoice
    Fig = figure;
    maximizeFig(Fig);
    for soundIdx = 1 : numel(RegMMNSequence)
        Temp = RegMMNSequence(soundIdx);
        Soundfreqpool = double(strsplit(string(regexpi(Temp.Name, 'Freq(.*?)_', 'tokens')), "-")); %Hz
        titleStr = strrep(string(regexpi(Temp.Name, '(.*?)_ISI', 'tokens')), "_", "-");
        StdITI = Temp.ITISeq(1);DevITI = Temp.ITISeq(end);
        t = [1/fs : 1/fs : numel(Temp.Wave)/fs] * 1000;

        subplot(4, 4, 1 + (soundIdx - 1) * numel(RegMMNSequence));% std single click wave
        plot(t, Temp.Wave); xlim([0, 2 * StdITI]);
        title(titleStr);

        subplot(4, 4, 2 + (soundIdx - 1) * numel(RegMMNSequence));% dev single click wave
        plot(t, Temp.Wave); xlim(Temp.StdDev_OnsetSeq(end) + [0 2 * DevITI]);
    
        subplot(4, 4, 3 + (soundIdx - 1) * numel(RegMMNSequence));% fft 
        [fftAmp, freq, ~, ~] = mfft(Temp.Wave, Temp.fs);
        plot(freq, fftAmp);hold on;lines = [];
        for freqIdx = 1 : numel(Soundfreqpool)
            lines(freqIdx).X = Soundfreqpool(freqIdx);
        end
        addLines2Axes(gca, lines);hold off;

        subplot(4, 4, 4 + (soundIdx - 1) * numel(RegMMNSequence));% cwt
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
%% export
mkdir(rootPath);
for sIndex = 1 : length(RegMMNSequence)
    audiowrite(strcat(rootPath, "\Reg_", RegMMNSequence(sIndex).Name), RegMMNSequence(sIndex).Wave, RegMMNSequence(sIndex).fs);
end
save(fullfile(rootPath, "MMNSequence.mat"), "RegMMNSequence");
end
