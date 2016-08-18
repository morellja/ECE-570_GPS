% sigGen.m
% Description:  Main program for signal generation using functions 
%               simGPSL1_1.m and simGPSL1_M.m
% Outputs:      simulated signals written to data files
% Date:         02/18/2011 (Jade Morton)
% Modified:     03/29/2011 (Jared Morell)

clc
clear all
close all

L = 0.1;                % Data length in s
fs = 50e6;              % Sampling frequency in Hz
nADC = 4;               % ADC bit number
B = 2e6;                % Front end bandwidth in Hz
PRN = [1 7 10 15];      % SV ID
CN0 = [45 47 49 30];    % carrier-to-noise ratio in dB-Hz
f0 = 1.25e6;            % ADC output center frequency in Hz
n0 = [1 1225 2500 4999];% Initial code pahse index
phi = [0 0.5 1.2 1.34]; % Carrier phase in radians
fd = [0 1100 2200 3000];% Carrier Doppler frequency in Hz
noiseFlag = 1;          % 1--add noise; 0--do not add noise
navFlag = 1;            % 1--add nav data bit; 0--do not add nav data bit

% Generate 50 MHz sampled signals
[xm_f] = simGPSL1_M(L, fs, f0, nADC, B, PRN, CN0, n0, phi, fd, noiseFlag, navFlag);

% Resample signal to achieve final sampling frequency of 5 MHz
ns = L*fs;          % total number of samples in signal
offset = 7;         % number of bits to offset resampled signal
s = 1:ns;           % sample index array
ind = s(mod(s,10) == offset); % new indices array
xm = xm_f(ind);

% Write the output to file
fileName='simGPSL1_M_50MHz_100ms.dat'; 
fid = fopen(fileName,'wb');  
fwrite(fid,xm,'schar');  
fclose(fid);

% Generate 5 MHz sampled signals
[xm] = simGPSL1_M(L, fs/10, f0, nADC, B, PRN, CN0, n0, phi, fd, noiseFlag, navFlag);

% Write the output to file
fileName='simGPSL1_M_5MHz_100ms.dat'; 
fid = fopen(fileName,'wb');  
fwrite(fid,xm,'schar');  
fclose(fid);


