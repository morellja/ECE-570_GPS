% HW_21.m
% Description:  Main program for generating GPS signal and then computing 
%               raw and filtered discriminator output

f0 = 1.25e6;        % ADC output center (Hz)
fs = 5e6;           % Sampling frequency (Hz)
ts = 1/fs;
TI = 1;             % Integration time (ms)
nd = 2;             % Correlator spacing (samples) btw early-prompt, prompt-late
B = 5;              % Filter equivalent noise bandwidth, Hz

% Assume perfect knowledge of Doppler & code phase
PRN = 7; 
fdEst= 1100; 
n0Est = 1225; 

% Read input data file, save signal to 'x', and convert to baseband
fid = fopen('simGPSL1_M_100ms.dat','r');
x = fread(fid,'schar'); fclose(fid);
ns = length(x);
xb = x'.*exp(-j*2*pi*f0*ts*[0:ns-1]);  % baseband signal

[Ld Lp] = DLLDiscrimFilterPlot(f0, fs, TI, nd, B, PRN, fdEst, n0Est, xb);
