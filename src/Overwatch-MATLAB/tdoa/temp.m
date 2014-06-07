% load('test/M_5chan.mat');
% load('test/audiodata5.mat');
addpath('../loc');
hold on;
clear testcase
testcase = TDOA(M_anders,RXXr);
testcase.Start;
testcase.R;
loctestcase = Loc();
location = loctestcase.Localize(testcase.R, testcase.MicrophoneLocations, testcase.settings.loc_threshold)
plot(location(1),location(2),'*');