%% Rat Linear Array
cd(fileparts(mfilename("fullpath")));
% ID = [127,127.1,127.2,127.3,127.4, 127.6, 128];
ID = [304, 302.2];
% ID = [221.3];
% ID = [104.1, 105.1, 108.1, 109.1, 1010, 121.1, 123.1, 123.2, 124.3, 124.4, 124.5];
for idx =1 : length(ID)
    TBOffsetGen("ID", ID(idx));
end


% %% Offset Variance
% cd(fileparts(mfilename("fullpath")));
% ID = [225.1, 225.2, 225.3, 225.4, 225.5];
% for idx = 1 : length(ID)
%     TBOffsetGen("ID", ID(idx));
% end

% %% Basic IFFT
% cd(fileparts(mfilename("fullpath")));
% % ID = [210.1, 210.2, 210.3, 210.4, 210.5]; % 4ms
% % ID = [210.1, 210.2, 210.3, 210.4, 210.5]+1; % 64ms
% % ID = [210.1, 210.2, 210.3, 210.4, 210.5]+2; % 8ms
% % ID = [210.1, 210.2, 210.3, 210.4, 210.5]+3; % 128ms
% 
% for idx = 1 : length(ID)
%     TBOffsetGen("ID", ID(idx));
% end
