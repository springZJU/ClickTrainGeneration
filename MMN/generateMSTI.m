%% Rat Linear Array
cd(fileparts(mfilename("fullpath")));
ID = [1];
for idx =1 : length(ID)
%     MSTIGen("ID", ID(idx));
    MSTIomiGen("ID", ID(idx));
end

