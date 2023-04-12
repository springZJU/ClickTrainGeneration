%% Rat Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [101.3];
for idx =1 : length(ID)
    MSTIGen("ID", ID(idx));
end

