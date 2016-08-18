% navBitsSamples.m
% Description:  Generates navigation data bits
% Inputs:       L, data length (s); fs, sampling frequency (Hz); fd,
%               Doppler frequency (Hz)
% Outputs:      sampled navigation data bits
% Date:         02/25/2011
% Modified:     N/A
% Creator:      Jade Morton

function navSamples = navBitsSamples(L,fs,fd)

% constants and variables
ts = 1/fs;          % sample interval (s)
Ns = L*fs;          % total number of samples in output
n = [1:Ns];         % sample index array
t = ts*(n-1);       % time vector (s)
fL1 = 1.57542e9;    % L1 band carrier frequency (Hz)
fb = 50*(1+fd/fL1); % effective navigation data rate (Hz)
tb = 1/fb;          % nav bit length (s)

% generate nav data bit samples
numberBits = round(L*1000/tb);
rawNavBits = round(rand(1,numberBits));
ind = find(rawNavBits==0);
rawNavBits(ind) = -1;
nb = floor(t/tb)+1;     % sample index mapped to bit index
navSamples = rawNavBits(nb);