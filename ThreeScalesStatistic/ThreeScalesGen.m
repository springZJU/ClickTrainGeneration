function ThreeScalesGen(varargin)

cd(fileparts(mfilename("fullpath")));

%% To get parameters
mIp = inputParser;
mIp.addParameter("xlsxPath", fullfile(fileparts(mfilename("fullpath")), ".\ThreeScales_ClickTrain_Config.xlsx"), @(x) isstring(x));
mIp.addParameter("ID", 101, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.parse(varargin{:});

xlsxPath = mIp.Results.xlsxPath;
ID = mIp.Results.ID;

ThreeScalesParams = ParseThreeScales_Params(xlsxPath, ID);
assignin("base", "clickTrainParams", ThreeScalesParams);
%% generate sounds
ThreeScalesParams.GenFcn(ThreeScalesParams);

end


