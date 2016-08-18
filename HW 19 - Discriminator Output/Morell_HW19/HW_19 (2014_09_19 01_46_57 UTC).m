% DLLDiscriminator6.m
% Description:  Computes DLL discriminator number 6 value
% Inputs:       f0, ADC output center, Hz
%               fs, Sampling frequency, Hz
%               TI, Integration time, ms
%               nd,Correlator spacing, samples
%               B, Filter equivalent noise bandwidth
%               PRN, PRN of desired SV
%               fdEst, estimated Doppler frequency, Hz
%               n0Est, estimated code phase
% Outputs:      L, DLL discriminator output for 100 ms of data
%               Lp, filtered output of DLL discriminator values for 100 ms
%               of data
%               Plots of L and Lp
% Date:         02/08/2011
% Modified:     05/01/2011 (Jared Morell)
% Author:       Jade Morton

clc
clear all
close all

f0 =1.25e6;         % ADC output center (Hz)
fs = 5e6;           % Sampling frequency (Hz)
ts = 1/fs;          % Sample period (s)
TI = 1;             % Integration time (ms)
nTI = TI*fs*1e-3;   % Number of samples in integration time
nd = 2;             % Correlator spacing (samples) btw early-prompt, prompt-late
B = 5;              % Filter equivalent noise bandwidth, Hz

% Assume perfect knowledge of Doppler & code phase
PRN = 4; 
fdEst= 1000; 
n0Est = 100; 

% Read input data file and save signal to 'x'
fid=fopen('simGPSL1_4SVs_100ms.dat','r');
x = fread(fid,'schar'); fclose(fid);
ns = length(x);
xb = x'.*exp(-j*2*pi*f0*ts*[0:ns-1]);  % baseband signal

% Compute discriminator for first TI ms data.
xTI = xb(1:nTI);
L(1) = DLLDiscriminator6(xTI, PRN, fs, fdEst, n0Est, nd, TI);
Lp(1) = L(1);

% Compute discriminator for each of the remaining ms of data and filter them.
for ii=2:99
    xTI=xb((ii-1)*nTI+1:ii*nTI);
    L(ii) = DLLDiscriminator6(xTI, PRN, fs, fdEst, n0Est, nd, TI);
    Lp(ii)=Lp(ii-1) + TI*1e-3*4*B*(L(ii)-Lp(ii-1));
end

% Plot
figure(1);
plot(1:99,L,'r+',1:99,Lp,'bo');
h = legend('Raw Discriminator','Filtered Output',2);
set(h,'Interpreter','none');
title(['Discriminator Output Before and After Applying Filter Using Filter' ...
    ' Equivalent Noise Bandwidth of ', num2str(B),' Hz']); 
xlabel('Time (ms)'); ylabel('Discriminator #6');

% Redo for different filter equivalent noise bandwidth
B=B+10;
for ii=2:99
    xTI=xb((ii-1)*nTI+1:ii*nTI);
    L(ii) = DLLDiscriminator6(xTI, PRN, fs, fdEst, n0Est, nd, TI);
    Lp(ii)=Lp(ii-1) + TI*1e-3*4*B*(L(ii)-Lp(ii-1));
end

figure(2);
plot(1:99,L,'r+',1:99,Lp,'bo');
h = legend('Raw Discriminator','Filtered Output',2);
set(h,'Interpreter','none');
title(['Discriminator Output Before and After Applying Filter Using Filter' ...
    ' Equivalent Noise Bandwidth of ', num2str(B),' Hz']); 
xlabel('Time (ms)'); ylabel('Discriminator #6');


