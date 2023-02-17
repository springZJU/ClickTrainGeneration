% %% Rat Linear Array
% cd(fileparts(mfilename("fullpath")));
% ID = [101:109, 121:126];
% for idx = 1 : length(ID)
%     TBOffsetGen("ID", ID(idx));
% end

% %% Offset Variance
% cd(fileparts(mfilename("fullpath")));
% ID = [225.1, 225.2, 225.3, 225.4, 225.5];
% for idx = 1 : length(ID)
%     TBOffsetGen("ID", ID(idx));
% end

%% Basic IFFT
cd(fileparts(mfilename("fullpath")));
% ID = [210.1, 210.2, 210.3, 210.4, 210.5]; % 4ms
% ID = [210.1, 210.2, 210.3, 210.4, 210.5]+1; % 64ms
% ID = [210.1, 210.2, 210.3, 210.4, 210.5]+2; % 8ms
ID = [210.1, 210.2, 210.3, 210.4, 210.5]+3; % 128ms
for idx = 1 : length(ID)
    TBOffsetGen("ID", ID(idx));
end
