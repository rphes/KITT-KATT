% Recording time
RecTime = 2;
Fs = 48000;

% mic5 = pa_wavrecord(1,5,RecTime*Fs,Fs,0,'asio');
% plot(mic5(:,5));

RecordData = {mic1, mic2, mic3, mic4, mic5};
save refdata RecordData