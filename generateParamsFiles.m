function generateParamsFiles(path,params)
paraNames = fields(params);
    for i = 1:length(paraNames)
        fName = [path '\' paraNames{i} '.txt'];
        dlmwrite(fName, params.(paraNames{i}),'delimiter', '\n')
    end
end

