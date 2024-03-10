clear;
%% MLA_MMN_5_4.5_4
meanNum1 = 30;
devType = 4;
SAVEPATH = 'M:\Random sequence stimuli\constant 6s ICI2,8,16';
orders = repmat((1:devType)', meanNum1, 1);
atts = repmat((ones(devType, 1) * 21.2)', meanNum1, 1); %
idx =randperm(meanNum1 * devType);
params.order = orders(idx);
params.att = atts(idx);
generateParamsFiles(SAVEPATH, params);


%% MLA_MMN_5_4.5_4_Dur300-150-150_ISI800-800-650
meanNum1 = 30;
devType = 12;
SAVEPATH = 'D:\ratClickTrain\parameters';
orders = repmat((1:devType)', meanNum1, 1);
atts = repmat((ones(devType, 1) * 21.2)', meanNum1, 1); %
idx =randperm(meanNum1 * devType);
params.orderMLAMSTIDur300_150_150 = orders(idx);
params.attMLAMSTIDur300_150_150 = atts(idx);
generateParamsFiles(SAVEPATH, params);
%% MLA_MSTI_BG_STD_DEV_BG
meanNumTest = 50;
meanNumControl = 20;
testType = 2;
totalType = 4;
SAVEPATH = 'D:\ratClickTrain\parameters';
orders = [repmat((1:testType)', meanNumTest, 1); repmat(((testType+1):totalType)', meanNumControl, 1)];
atts = repmat([21.2], meanNumTest * testType + meanNumControl * (totalType - testType), 1); 
idx =randperm(meanNumTest * testType + meanNumControl * (totalType - testType));
params.orderMLAMSTI_G4_BG_STD_DEV_BG = orders(idx);
params.attMLAMSTI_G4_BG_STD_DEV_BG = atts(idx);
generateParamsFiles(SAVEPATH, params);

%% MLA_MSTIomi
clear;clc;
meanNum1 = 30;
devType = 4;
SAVEPATH = 'D:\ratClickTrain\parameters';
orders = repmat((1:devType)', meanNum1, 1);
atts = repmat((ones(devType, 1) * 21.2)', meanNum1, 1); %
idx =randperm(meanNum1 * devType);
% params.orderMSTIomi_G2 = orders(idx);
% params.attMSTIomi_G2 = atts(idx);
params.order_G4_30 = orders(idx);
params.att_G4_30 = atts(idx);
generateParamsFiles(SAVEPATH, params);