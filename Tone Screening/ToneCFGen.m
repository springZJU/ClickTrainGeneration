function ToneCF = ToneCFGen(varargin)

cd(fileparts(mfilename("fullpath")));

%% To get parameters
mIp = inputParser;
mIp.addParameter("xlsxPath", fullfile(fileparts(mfilename("fullpath")), ".\ToneCFParameters_For_Generation.xlsx"), @(x) isstring(x));
mIp.addParameter("ID", 1, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive', 'integer'}));
mIp.parse(varargin{:});

xlsxPath = mIp.Results.xlsxPath;
ID = mIp.Results.ID;

ToneCFParams = ParseToneCFParams(xlsxPath, ID);
assignin("caller", "fs", ToneCFParams.fs);
%% generate sounds
ToneCF = ToneCFParams.GenFcn(ToneCFParams);

end





