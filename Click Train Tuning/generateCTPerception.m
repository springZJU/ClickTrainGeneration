%% Rat Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [106];
for idx =1 : length(ID)
    CTPerceptionGen("ID", ID(idx));
end
ccc