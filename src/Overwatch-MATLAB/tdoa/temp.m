load('test/M_5chan.mat');
load('test/audiodata5.mat');
clear testcase
testcase = TDOA(M_anders,RXXr);
testcase.Start  % hier zit de error: 
                % Attempt to reference field of non-structure array.
                % 
                % Error in TDOA/Start (line 154)
                %             Self = set(Self,'R',Self.RangeDiff());
