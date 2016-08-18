% simGPSL1_1.m
% Description:  Generates a simulated GPS L1 band signal for one satellite
% Inputs:       L, data length (s)
%               fs, sampling frequency (Hz)
%               f0, ADC output center frequency (Hz)
%               nADC, number of bits used in ADC
%               B, front end bandwidth (Hz)
%               PRN, PRN for desired satellite
%               CN0, carrier-to-noise ratio (dB-Hz)
%               n0, initial code phase index
%               phi, carrier phase (radians)
%               fd, carrier Doppler frequency (Hz)
%               noiseFlag, 1 if thermal noise should be added to signal
%               navFlag, 1 if navigation data should be modulated
% Outputs:      x, received digitized signal
% Date:         02/18/2011 (Jade Morton)
% Modified:     03/29/2011 (Jared Morell)

function [x] = simGPSL1_1(L, fs, f0, nADC, B, PRN, CN0, n0, phi, fd, noiseFlag, navFlag)

% Constants and variables
fc = 1.023e6;           % L1 CA code chipping rate in Hz
fL1 = 1.57542e9;        % L1 carrier frequency in Hz
ts = 1/fs;              % Sample interval (s)
ns1 = 1e-3*fs;          % Sample # in one code period.
ns = L*fs;              % Total number of samples
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
x = A*CA_shift.*cos(2*pi*(f0+fd)*ts*[0:ns-1] + phi); % Complete signal sequence

% Add thermal noise if desired.
if (noiseFlag == 1) 
    noise = sqrt(B*Pn)*randn(1, ns); 
    x = x+noise;  
end

% Scale the output to the range of a fully exercised nADC bits
maxX = max(abs(x));  
x = x * 2^(nADC-1)/ maxX;   
x = round(x);


