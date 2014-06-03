% Fix path
addpath(genpath('.'));

% Create wrapper object with initial location
InitialLocation = [0 0];
MicrophoneLocations = [];
wrapper = Wrapper(InitialLocation, MicrophoneLocations);

% Create anonymous function for C# to call
loop = @() wrapper.Loop();