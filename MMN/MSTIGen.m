function MSTIGen(varargin)

cd(fileparts(mfilename("fullpath")));

%% To get parameters
mIp = inputParser;
mIp.addParameter("xlsxPath", fullfile(fileparts(mfilename("fullpath")), ".\MSTI_ClickTrain_Config.xlsx"), @(x) isstring(x));
mIp.addParameter("ID", 1, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.parse(varargin{:});

xlsxPath = mIp.Results.xlsxPath;
ID = mIp.Results.ID;

MSTIParams = ParseMSTI_Params(xlsxPath, ID);
assignin("base", "MSTIParams", MSTIParams);

%% generate sounds
MSTIParams.GenFcn(MSTIParams);

end


