%% Rat Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [101.1, 102.1];
for idx =1 : length(ID)
    CTPerceptionGen("ID", ID(idx));
end
