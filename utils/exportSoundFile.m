function exportSoundFile(waveData, opts)

optsNames = fieldnames(opts);
for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end


if numel(ICIName) ~= length(waveData) && numel(ICIName) / 2 ~= length(waveData) 
    error('size ICIName differ from size waveData !!!');
end

disp(['find ', num2str(length(waveData)), ' sound waves to exported ...']);

if ~exist(fullfile(rootPath, folderName), 'dir')
    mkdir(fullfile(rootPath, folderName));
end

for i = 1 : length(waveData)
    if numel(ICIName) == length(waveData)
        disp(['exporting wave ', strrep(fileNameTemp, fileNameRep, num2str(ICIName(i))), ' ...']);
        fileName = strrep(fullfile(rootPath, folderName, fileNameTemp), fileNameRep, num2str(ICIName(i)));
    elseif numel(ICIName) == 2 * length(waveData)
        disp(strcat("exporting wave ", strrep(fileNameTemp, fileNameRep, strcat(num2str(ICIName(i, 1)), "_", num2str(ICIName(i, 2)))), " ..."));
        fileName = strrep(fullfile(rootPath, folderName, fileNameTemp), fileNameRep, strcat(num2str(ICIName(i, 1)), "_", num2str(ICIName(i, 2))));
    else
        error("ICIName is not correct!");
    end

    audiowrite(fileName, waveData{i}, fs);
end
end
