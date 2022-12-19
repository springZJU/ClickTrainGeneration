cd(fileparts(mfilename("fullpath")));
%% generate sound
ID = [101:109, 121:126];
for idx = 1 : length(ID)
    TBOffsetGen("ID", ID(idx));
end

