% sigGen.m
% Description:  Main program for signal generation using functions 
%               simGPSL1_1.m and simGPSL1_M.m
% Outputs:      simulated signals written to data files
% Date:         02/18/2011 (Jade Morton)
% Modified:     03/29/2011 (Jared Morell)

clc
clear all
close all

L = 0.002;              % Data length in s
fs = 5e6;               % Sampling frequency in Hz
nADC = 4;               % ADC bit number
B = 2e6;                % Front end bandwidth in Hz
PRN = [4 7 10 15];      % SV ID
CN0 = [45 47 49 49];    % carrier-to-noise ratio in dB-Hz
f0 = 1.25e6;            % ADC output center frequency in Hz
n0 = [100 1225 2500 4999];% Initial code pahse index
phi = [0 0 0 0];        % Carrier phase in radians
fd = [  600 2000 3000];% Carrier Doppler frequency in Hz
noiseFlag = 1;          % 1--add noise; 0--do not add noise
navFlag = 1;            % 1--add nav data bit; 0--do not add nav data bit

% Generate signals
[x] = simGPSL1_1(L, fs, f0, nADC, B, PRN(1), CN0(1), n0(1), phi(1), fd(1), noiseFlag, navFlag);
[xm] = simGPSL1_M(L, fs, f0, nADC, B, PRN, CN0, n0, phi, fd, noiseFlag, navFlag);

% Write the output to files
fileName='simGPSL1_1.dat';  
fid = fopen(fileName,'wb');  
fwrite(fid,x,'schar');  
fclose(fid);

fileName='simGPSL1_M.dat'; 
fid = fopen(fileName,'wb');  
fwrite(fid,xm,'schar');  
fclose(fid);


