function TBOffsetGen(varargin)

cd(fileparts(mfilename("fullpath")));

%% To get parameters
mIp = inputParser;
mIp.addParameter("xlsxPath", fullfile(fileparts(mfilename("fullpath")), ".\TBOffset_ClickTrain_Config.xlsx"), @(x) isstring(x));
mIp.addParameter("ID", 101, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.parse(varargin{:});

xlsxPath = mIp.Results.xlsxPath;
ID = mIp.Results.ID;

TBOffsetParams = ParseTB_Offset_Params(xlsxPath, ID);
assignin("caller", "fs", TBOffsetParams.fs);

%% generate sounds
TBOffsetParams.GenFcn(TBOffsetParams);

end


