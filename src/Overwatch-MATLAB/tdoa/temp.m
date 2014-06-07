close all;
% load('test/M_5chan.mat'); %this is for the audiomeasure5
% load('test/M_22chan.mat'); %this is for the audiomeasure22
% load('test/audiodata5.mat'); 
addpath('../loc');
ii=[1 
    2 
    3 
    4 
    5 
    6 
    7];
for i=1:length(ii)
    clear testcase
    testcase = TDOA(M_22,RXXr,ii(i));
    testcase.Start;
    loctestcase = Loc();
    location = loctestcase.Localize(testcase.R, testcase.MicrophoneLocations, testcase.settings.loc_threshold);
    hold on;
    plot(location(1),location(2),'ro','MarkerSize',20,'MarkerFaceColor','r');
    hold off;
end
for i=1:5
    hold on;
    plot(testcase.MicrophoneLocations(i,1),testcase.MicrophoneLocations(i,2),'bo','MarkerSize',20,'MarkerFaceColor','b');
    hold off;
end