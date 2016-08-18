% Program Name: signalGen.m
% Description:  signal generator for GPS L1 signal
% Inputs:       L,              code length, in miliseconds
%               fs,             sampling frequency
%               f0,             ADC output center frequency in MHz
%               nADC,           ADC bit number
%               B,              Front end bandwidth in Hz
%               PRN,            user specified GPS SV ID
%               CN0,            carrier to noise ration in dB-Hz
%               n0,             initial code pahse index
%               phi,            carrier phase in radians
%               fd,             carrier doppler frequency in Hz
%               noiseFlag,      1--add noise; 0--do not add noise
%               navFlag,        1--add navigation data bit; 0--do not add
%                               navigation data bit
% Output:       simGPSL1_1.dat, simulated output for a single satellite
%               simGPSL1_M.dat, simulated output for multiple satellites
% Programmer:   Dr. Jade Morton
% Date Written: N/A
% Date Modified:4/1/2011

clear all;
L=2e-3;                     % Data length in s
fs= 5e6;                    % Sampling frequency in ms
nADC= 4;                    % ADC bit number
B = 2e6;                    % Front end bandwidth in Hz
PRN =[4 7 10 15];           % SV ID
CN0 =[47 47 50 46];         % dB-Hz
f0 = 1.25e6;                % ADC output center frequency in MHz
n0 = [100 1225 2500 4999];  % Initial code pahse index
phi = [0 0 0 0];            % Carrier phase in radians
fd= [300 600 2000 3000];    % Carrier Doppler frequency in Hz
noiseFlag= 1;               % 1--add noise; 0--do not add noise
navFlag= 1;                 % 1--add navigation data bit; 0--do not add navigation data bit

% Generate signals
[x] = simGPSL1_1(L, fs, f0, nADC, B, PRN(1), CN0(1), n0(1), phi(1), fd(1), noiseFlag, navFlag);
[xm] = simGPSL1_M(L, fs, f0, nADC, B, PRN, CN0, n0, phi, fd, noiseFlag, navFlag);

% Write the output to file
fileName='simGPSL1_1_2ms.dat'; fid = fopen(fileName,'wb'); fwrite(fid,x,'schar'); fclose(fid);
fileName='simGPSL1_M_2ms.dat'; fid = fopen(fileName,'wb'); fwrite(fid,xm,'schar'); fclose(fid);