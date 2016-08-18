% acquisition_Doppler.m
% Description:  This program computes relative correlation of the peak
%               power loss between CA codes with and without navigation
%               data bit transition occurring in the middle of the period
% Inputs:       L, data length
%               fs, sampling frequency
%               PRN, SV PRN for CA code
% Outputs:      fd_L1, max Doppler frequency of L1 carrier
%               fd_L5, max Doppler frequency of L5 carrier
%               fd_L2C_code, max Doppler frequency of L2C code
%               fd_L5_code, max Doppler frequency of L5 code
%               relative correlation power loss between the two CA codes
% Date:         03/27/2011
% Modified:     N/A
% Creator:      Jared Morell

clc
clear all
close all

% inputs
L = 1e-3;       % data length (s)
fs = 5e6;       % sampling frequency (Hz)
PRN = 1;        % satellite PRN for CA code

% constants and variables
fL1 = 1.57542e9;    % L1 band carrier frequency (Hz)
fL5 = 1.17645e9;    % L5 band carrier frequency (Hz)
fL2C_code = 1.023e6;% L2C code frequency (Hz)
fL5_code = 10.23e6; % L5 code frequency (Hz)
vLOS = 930;         % max LOS velocity for a SV (m/s)
c = 2.99792458e8;   % speed of light (m/s)
m = L/(0.001);      % number of CA code periods

% generate CA codes
CA = CASamples(m,fs,PRN,0,0);
CAnav = CASamples(m,fs,PRN,0,0);

% simulate data bit transition in second half of CA code
CAlength = length(CAnav);
ind = round(CAlength/2);
while ind < CAlength+1
    CAnav(ind) = -1*CAnav(ind);
    ind = ind+1;
end

% compute cross correlation between CA codes and auto-correlation of CA
% code without data bit transition
corr = crossCorr(CA,CAnav);
auto = crossCorr(CA,CA);

% calculate max Doppler frequencies
fd_L1 = fL1*vLOS/c             % max L1 band carrier Doppler frequency (Hz)
fd_L5 = fL5*vLOS/c             % max L5 band carrier Doppler frequency (Hz)
fd_L2C_code = fL2C_code*vLOS/c % max L2C code Doppler frequency (Hz)
fd_L5_code = fL5_code*vLOS/c   % max L5 code Doppler frequency (Hz)

% calculate time required to mis-align L2C and L5 codes by 1/2 chip
nL2C = round(fL2C_code/(2*fd_L2C_code*1023))  % ms
nL5 = round(fL5_code/(2*fd_L5_code*1023))    % ms

% plot reference CA code and correlation between reference and CA code with
% navigation data bit transition
len=length(corr);
x = 0:len-1;      % samples vector
figure;
subplot(2,1,1); plot(x,corr,'r');
title('Cross-Correlation between CA codes with and without data bit transition'); 
xlabel('Index'); ylabel('Correlation Value');     
subplot(2,1,2); plot(x,auto,'b');
title('Auto-Correlation of CA code without data bit transition'); 
xlabel('Index'); ylabel('Correlation Value');


