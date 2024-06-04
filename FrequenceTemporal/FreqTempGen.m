function FreqTempGen(varargin)

cd(fileparts(mfilename("fullpath")));

%% To get parameters
mIp = inputParser;
mIp.addParameter("xlsxPath", fullfile(fileparts(mfilename("fullpath")), ".\FreqTemp_Toneburst_Config.xlsx"), @(x) isstring(x));
mIp.addParameter("ID", 1, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.parse(varargin{:});

xlsxPath = mIp.Results.xlsxPath;
ID = mIp.Results.ID;

clickTrainParams = ParseFreqTemp_Params(xlsxPath, ID);
assignin("caller", "fs", clickTrainParams.fs);

%% generate sounds
clickTrainParams.GenFcn(clickTrainParams);

end


