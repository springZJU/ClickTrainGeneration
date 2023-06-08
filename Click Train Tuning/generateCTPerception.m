%% Rat Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [104, 105];
for idx =1 : length(ID)
    CTPerceptionGen("ID", ID(idx));
end
