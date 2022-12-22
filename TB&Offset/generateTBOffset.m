%% Rat Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [101:109, 121:126];
for idx = 1 : length(ID)
    TBOffsetGen("ID", ID(idx));
end

%% Monkey Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [225:226];
for idx = 1 : length(ID)
    TBOffsetGen("ID", ID(idx));
end

