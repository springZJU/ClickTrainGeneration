%% Rat Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [102.1, 103];
for idx =1 : length(ID)
    ThreeScalesGen("ID", ID(idx));
end

