%% difference + Base ICI
run("generateClickTrain_RatECoG_Ratio.m");

%% Duration 1
run("generateClickTrain_RatECoG_Duration.m");

%% Duration 2
singleDuration = 30;
run("generateSuccessiveClickTrain_RatECoG.m");

singleDuration = 60;
run("generateSuccessiveClickTrain_RatECoG.m");

singleDuration = 125;
run("generateSuccessiveClickTrain_RatECoG.m");

singleDuration = 250;
run("generateSuccessiveClickTrain_RatECoG.m");

singleDuration = 500;
run("generateSuccessiveClickTrain_RatECoG.m");

%% Variance
run("generateClickTrain_RatECoG_Var.m");

% %% control
% run("generateClickTrain_RatECoG_Intense.m");
% run("generateClickTrain_RatECoG_Reg_In_Irreg.m")
