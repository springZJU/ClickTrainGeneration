%% Rat Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [101, 102];
for idx =1 : length(ID)
    CTPerceptionGen("ID", ID(idx));
end
