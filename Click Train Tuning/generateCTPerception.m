%% Rat Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [103.1];
for idx =1 : length(ID)
    CTPerceptionGen("ID", ID(idx));
end
