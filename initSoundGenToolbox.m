function initSoundGenToolbox
rootpath = fullfile(fileparts(mfilename("fullpath")));
addpath(rootpath);
addpath(genpath(fullfile(rootpath, "BPN")));
addpath(genpath(fullfile(rootpath, "Click Train Tuning")));
addpath(genpath(fullfile(rootpath, "FrequenceTemporal")));
addpath(genpath(fullfile(rootpath, "MMN")));
addpath(genpath(fullfile(rootpath, "MultiTone")));
addpath(genpath(fullfile(rootpath, "TB&Offset")));
addpath(genpath(fullfile(rootpath, "ThreeScalesStatistic")));
addpath(genpath(fullfile(rootpath, "Tone Screening")));
addpath(genpath(fullfile(rootpath, "utils")));
addpath(genpath(fullfile(rootpath, "v2.0")));
