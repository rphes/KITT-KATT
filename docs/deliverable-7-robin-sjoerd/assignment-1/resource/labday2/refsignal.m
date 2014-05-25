function [x,last] = refsignal(Ncodebits,Timer0,Timer1,Timer3,code,Fs);
% Input: Ncodebits,Timer0,Timer1,Timer2,code, as for the AVR
%       Extension: If Timer0 == -1, then no carrier modulation
%       Fs: sample rate at which to generate the template (e.g., 40e3)
%
% The default parameters of the audio beacon are obtained using
%     x = refsignal(32,3,8,2,'92340f0faaaa4321',Fs);
%
% Output:
%     x: the transmitted signal (including silence period)
%     last: the last sample before the silence period


% first perform sanity checks on the input
error(nargchk(6,6,nargin,'struct'));	% expect 6 input arguments
error(nargchk(0,2,nargout,'struct'));	% expect 0 to 2 output arguments
if ~isnumeric(Ncodebits), error('refsignal','Ncodebits must be an integer'); end
if ~isnumeric(Timer0), error('refsignal','Timer0 must be an integer '); end
if ~isnumeric(Timer1), error('refsignal','Timer1 must be an integer'); end
if ~isnumeric(Timer3), error('refsignal','Timer3 must be an integer'); end
if ~ischar(code), error('refsignal','code must be a hex string'); end
if ~isnumeric(Fs), error('refsignal','Fs must be a real'); end

% arrays to match Timerx to frequencies (Hz)
FF0 = [0 5 10 15 20 25 30]*1e3;
FF1 = [1 1.5 2 2.5 3 3.5 4 4.5 5]*1e3;
FF3 = [1 2 3 4 5 6 7 8 9 10];

% compute corresponding frequencies (Hz)
f0 = FF0(Timer0+2);	% (also allow for '-1' as input)
f1 = FF1(Timer1+1);
f3 = FF3(Timer3+1);

% convert hex code string into binary string
bincode = [];
for ii = 1:length(code),
    symbol = code(ii);
    bits = dec2bin(hex2dec(symbol),4);	% 4 bits for a hex symbol
    bincode = strcat(bincode , bits);
end

% Generate template
Nx = round(Fs/f3);	% number of samples in template vector (integer)
x = zeros(Nx,1);

Np = Fs/f1;		% number of samples of one "Timer1" period (noninteger)
for ii = 1:Ncodebits,
   index = [round((ii-1)*Np+1) : round(ii*Np)];
   bit = bincode(ii) == '1';	% convert from char '0' or '1' to integer 0 or 1
   x( index ) = ones(length(index),1) * bit;
end

% modulate x on a carrier with frequency f0
carrier = cos(2*pi*f0/Fs*[0:Nx-1]);
xmod = round( carrier + 1 )';	% convert sine wave to block pulses


x = x .* xmod;

% compute location of last nonzero sample
last = round(Ncodebits*Np) - 1;

return
