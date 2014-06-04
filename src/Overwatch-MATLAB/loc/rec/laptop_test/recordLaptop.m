%% Test audio recording on laptop
function y = recordLaptop(time)
    % Time is the number of seconds to record
    time = ceil(time);
    Fs = 44100; %samplerate
    resolution = 16; %bit resolution
    recObj = audiorecorder(Fs,resolution,1);
    record(recObj);
    pause(time);
    stop(recObj)
    disp('Recoding finished');
    y=recObj.getaudiodata;
%     plot(y)
end