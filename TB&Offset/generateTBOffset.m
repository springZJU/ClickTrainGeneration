% %% Rat Linear Array
% cd(fileparts(mfilename("fullpath")));
% ID = [101:109, 121:126];
% for idx = 1 : length(ID)
%     TBOffsetGen("ID", ID(idx));
% end

%% Monkey Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [225.1, 225.2, 225.3, 225.4, 225.5];
for idx = 1 : length(ID)
    TBOffsetGen("ID", ID(idx));
end

