close all;
% load('test/M_5chan.mat'); %this is for the audiomeasure5
% load('test/M_22chan.mat'); %this is for the audiomeasure22
% load('test/audiodata5.mat'); 
addpath('../loc');
ii=[
    1 %niet echt
    2 %nee
    3 %nee
    4 %nee
    5 %nee
    6 %nee
    7 %nee
    ];
clear testcase
clear location
clear loctestcase

for i=1:length(ii)
    testcase{i} = TDOA(RXXr,ii(i),x);
    testcase{i}.Start;
    loctestcase = Loc();
    location{i} = loctestcase.Localize(testcase{i}.R, testcase{i}.MicrophoneLocations, testcase{i}.settings.loc_threshold);
    a=i;
end

figure
for i=1:5
    hold on;
    plot(testcase{a}.MicrophoneLocations(i,1),testcase{a}.MicrophoneLocations(i,2),'bo','MarkerSize',20,'MarkerFaceColor','b');
    hold off;
end

for i=1:a
    hold on;
    plot(location{i}(1),location{i}(2),'ro','MarkerSize',20,'MarkerFaceColor','r');
    hold off;
end