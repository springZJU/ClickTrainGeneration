mPath = mfilename("fullpath");
cd(fileparts(mPath));
singleDuration = 30;
run("generateSuccessiveClickTrain_RatLinearArray.m");

singleDuration = 60;
run("generateSuccessiveClickTrain_RatLinearArray.m");

singleDuration = 125;
run("generateSuccessiveClickTrain_RatLinearArray.m");

singleDuration = 250;
run("generateSuccessiveClickTrain_RatLinearArray.m");

singleDuration = 500;
run("generateSuccessiveClickTrain_RatLinearArray.m");
