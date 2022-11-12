mPath = mfilename("fullpath");
cd(fileparts(mPath));




%% difference + Base ICI
run("generateClickTrain_MonkeyECoG_Ratio.m");

%% Duration 1
run("generateClickTrain_MonkeyECoG_Duration.m");

%% Duration 2
singleDuration = 30;
run("generateSuccessiveClickTrain_MonkeyECoG.m");

singleDuration = 60;
run("generateSuccessiveClickTrain_MonkeyECoG.m");

singleDuration = 125;
run("generateSuccessiveClickTrain_MonkeyECoG.m");

singleDuration = 250;
run("generateSuccessiveClickTrain_MonkeyECoG.m");

singleDuration = 500;
run("generateSuccessiveClickTrain_MonkeyECoG.m");

%% Variance
run("generateClickTrain_MonkeyECoG_Var.m");

%% control
run("generateClickTrain_MonkeyECoG_Intense.m");
run("generateClickTrain_MonkeyECoG_Reg_In_Irreg.m")
