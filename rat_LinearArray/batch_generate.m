mPath = mfilename("fullpath");
cd(fileparts(mPath));




%% difference + Base ICI
run("generateClickTrain_RatLinearArray_Ratio.m");

%% Duration 1
run("generateClickTrain_RatLinearArray_Duration.m");

%% Duration 2
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

%% Variance
run("generateClickTrain_RatLinearArray_Var.m");

%% control
run("generateClickTrain_RatLinearArray_Intense.m");
run("generateClickTrain_RatLinearArray_Reg_In_Irreg.m")
