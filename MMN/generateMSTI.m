%% Rat Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [304.16, 304.17, 304.18];
for idx =1 : length(ID)
    MSTIGen("ID", ID(idx));
end

