%% Rat Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [102.2, 102.3];
for idx =1 : length(ID)
    MSTIGen("ID", ID(idx));
end

