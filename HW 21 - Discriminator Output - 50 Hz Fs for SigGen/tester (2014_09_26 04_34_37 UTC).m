clc
clear all
close all

L = 0.1;                % Data length in s
fs = 5e6;               % Sampling frequency in Hz
nADC = 4;               % ADC bit number
B = 2e6;                % Front end bandwidth in Hz
PRN = 7;                % SV ID
CN0 = 47;               % carrier-to-noise ratio in dB-Hz
f0 = 1.25e6;            % ADC output center frequency in Hz
n0 = 1225;              % Initial code pahse index
phi = 0.5;              % Carrier phase in radians
fd = 1100;              % Carrier Doppler frequency in Hz
noiseFlag = 1;          % 1--add noise; 0--do not add noise
navFlag = 1;            % 1--add nav data bit; 0--do not add nav data bit

% Constants and variables
fc = 1.023e6;           % L1 CA code chipping rate in Hz
fL1 = 1.57542e9;        % L1 carrier frequency in Hz
ts = 1/fs;              % Sample interval (s)
ns1 = 1e-3*fs;          % Sample # in one code period.
ns = L*fs;              % Total number of samples
n = [0:ns/10-1];        % Sample index array
fc = fc*(1+fd/fL1);     % Effective code rate in Hz
tc = 1/fc;              % Effective code chip length
k = 1.38e-23;           % Boltzman constant
TK = 535;               % Equivalent noise temperature in Kelvin
Pn = k*TK;              % Noise power density

% Generate GPS Signal
A = sqrt(2*Pn)*10^(CN0/20);     % Signal amplitude
CA = CASamples(L, fs, fd, PRN); % CA code samples
if (navFlag == 1)               % Add Nav data modulation
    CA = CA .* navBitsSamples(L, fs, fd); 
end 
icp = ns - n0 + 2; 
CA_shift = [CA(icp:ns) CA(1:ns-n0+1)];   % Shift CA code to desired phase

% Sampled at 50 MHz, but take 1 of every 10 samples to return to fs = 5 MHz
ii = 1;
x = zeros(1,length(CA)/10);
while ii < length(CA)/10;
    % Complete signal sequence:
    x(ii) = A*CA_shift((ii-1)*10+1).*cos(2*pi*(f0+fd)*ts*n(ii) + phi); 
    ii = ii+1;
end

% Add thermal noise if desired.
if (noiseFlag == 1) 
    noise = sqrt(B*Pn)*randn(1, ns/10); 
    x = x+noise;  
end

% Scale the output to the range of a fully exercised nADC bits
maxX = max(abs(x));  
x = x * 2^(nADC-1)/ maxX;   
x = round(x);
