function CTPerceptionGen(varargin)

cd(fileparts(mfilename("fullpath")));

%% To get parameters
mIp = inputParser;
mIp.addParameter("xlsxPath", fullfile(fileparts(mfilename("fullpath")), ".\ClickTrain_Perception_Config.xlsx"), @(x) isstring(x));
mIp.addParameter("ID", 101, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.parse(varargin{:});

xlsxPath = mIp.Results.xlsxPath;
ID = mIp.Results.ID;

CTPerceptionParams = ParseCT_Perception_Params(xlsxPath, ID);
assignin("caller", "fs", CTPerceptionParams.fs);

%% generate sounds
CTPerceptionParams.GenFcn(CTPerceptionParams);

end


