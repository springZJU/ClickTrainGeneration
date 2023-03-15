function multiTone = MultiToneGen(varargin)

%% To get parameters
mIp = inputParser;
mIp.addParameter("xlsxPath", fullfile(fileparts(mfilename("fullpath")), ".\multiToneParameters_For_Generation.xlsx"), @(x) isstring(x));
mIp.addParameter("ID", 1, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive', 'integer'}));
mIp.parse(varargin{:});

xlsxPath = mIp.Results.xlsxPath;
ID = mIp.Results.ID;

MultiToneParams = ParseMultiToneParams(xlsxPath, ID);
% multiTone = MultiTone_S1S2Overlap_Gen(MultiToneParams);
multiTone = MultiToneParams.GenFcn(MultiToneParams);

end





