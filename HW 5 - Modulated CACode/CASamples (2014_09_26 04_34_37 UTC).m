% CASamples.m
% Description:  Decimates a specified number of periods of CA Code
%               according to a specified sampling frequency, PRN, and 
%               Doppler frequency of the SV
% Inputs:       Number of periods of code,m; sampling frequency, fs; PRN
%               for desired satellite code; and Doppler frequency, fd
% Outputs:      The sampled CA code
% Date:         02/08/2011
% Modified:     02/23/2011
% Creator:      Jared Morell

function samples=CASamples(m,fs,PRN,fd)

% Constants and variables
fc = 1.023e6;           % chip rate (Hz)
fL1 = 1.57542e9;        % L1 band carrier frequency (Hz)
fc = fc*(1+fd/fL1);     % Doppler shifted chip rate (Hz)
T = 1e-3;               % CA code period (s)
tc = 1/fc;              % chipping period (s)
ts = 1/fs;              % sampling period (s)
numSamps = m*fs*T;      % number of samples
t = ts*(0:numSamps-1);  % time vector (s)

% Convert CA Gold Code array to code samples
code = CACode(PRN);         % get Gold code
code(find(code==0))=-1;     % set 0's to -1's
nc = floor(t/tc) + 1;       % map time to code index
nc_m = rem((nc-1),1023) + 1;% map code index to code period
samples = code(nc_m);       % sampled CA code