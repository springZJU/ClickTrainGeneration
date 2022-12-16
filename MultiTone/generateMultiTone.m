cd(fileparts(mfilename("fullpath")));
%% generate sound
ID = 2;
multiTone = MultiToneGen("id", ID);

%% save folder
folderName = strcat("MultiTone_ID", num2str(ID));
rootPath = fullfile('..\..\monkeySounds', strcat(datestr(now, "yyyy-mm-dd"), "_", folderName));
mkdir(rootPath);
%% export
for sIndex = 1 : length(multiTone)
% export S1S2
soundName = strcat(rootPath, "\S1S2_", multiTone(sIndex).Info, ".wav");
audiowrite(soundName, multiTone(sIndex).S1S2, fs);
% export S2S1
soundName = strcat(rootPath, "\S2S1_", multiTone(sIndex).Info, ".wav");
audiowrite(soundName, multiTone(sIndex).S2S1, fs);
end

save(fullfile(rootPath, "multiTone.mat"), "multiTone");

