clear; clc;
cd(fileparts(mfilename("fullpath")));

ID = [1.4];
checkChoice = true;

for idx =1 : length(ID)
    FreqTempGen("ID", ID(idx));
end
