%% Rat Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [101.1, 101.2];
for idx =1 : length(ID)
    MSTIGen("ID", ID(idx));
end

