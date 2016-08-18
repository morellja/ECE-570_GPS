% PLL.m
% Description:  Implements 2nd order PLL based on bilinear transformation 
%               without code tracking loop feedback
% Inputs:       fs, sampling frequency
%               f0, Output center frequency
%               TI, Integration time in ms
%               n1, Number of samples in 1 ms
%               PRN, desired satellite ID
%               fdEst, estimated Doppler frequency
%               n0Est, estimated code phase
%               phi0, estimated carrier phase
% Outputs:      L2, PLL Costas discriminator #2 output for 100 ms of data
%               Lf, filtered output of Costas discriminator values for 100
%               ms of data
%               Plots of L and Lf
% Date:         02/08/2011
% Modified:     05/02/2011 (Jared Morell)
% Author:       Jade Morton

clc
clear all
close all

% Constants
fs = 5e6;         % Sampling frequency
f0 = 1.25e6;      % Output center frequency
TI = 1;           % Integration time in ms
n1 = fs*1e-3;     % Number of samples in 1 ms
nTI = TI*fs*1e-3; % Number of samples in integration time
rad2deg = 180/pi; % Convert radians to degrees

% PLL parameters
a2 = 1.4;           % Damping factor;
B = 5;              % Equivalent noise bandwidth in Hz
wn = B*4/(a2+1/a2);

% Bilinear transformation transfer function coefficients
wnTI = wn*TI*1e-3; wnTI2 = (wnTI)^2; wnTIa2 = wnTI*a2*2;
b0 = wnTI2 + wnTIa2;
b1 = 2*wnTI2;
b2 = wnTI2 - wnTIa2;
d0 = wnTI2 + wnTIa2 + 4;
d1 = 2*wnTI - 8;
d2 = wnTI2 - wnTIa2 + 4;

% User inputs: parameters used to simulate the signal
PRN = 4; fdEst = 1000; n0Est = 100; phi0=0;

% Read input data
fileName = 'simGPSL1_4SVs_100ms.dat';
fid = fopen(fileName,'r');
x = fread(fid,'schar'); fclose(fid);
ns = length(x);

% Inputs from acquisition or prior tracking
fdTrk = fdEst;
xb = x'.*exp(-j*2*pi*(f0+fdTrk)*[0:ns-1]/fs);
Code = CASamples(TI,fs,fdTrk,PRN);
CP = [Code(nTI-n0Est+2:nTI) Code(1:nTI-n0Est+1)];

for ii=1:2
    xTI = xb((ii-1)*nTI+1:ii*nTI);
    [L2(ii),ZP(ii)]=CostasDiscriminator2(xTI,CP);
    Lf(ii) = L2(ii);
end

nBlocks = floor(ns/nTI);
for ii = 3:nBlocks
    xTI = xb((ii-1)*nTI+1:ii*nTI);
    [L2(ii), ZP(ii)] = CostasDiscriminator2(xTI, CP);
    Lf(ii)=(b0*L2(ii)+b1*L2(ii-1)+b2*L2(ii-2)-d1*Lf(ii-1)- ...
        d2*Lf(ii-2))/d0;
end

% Plot Discriminator output before and after filtering
figure(1);
plot(1:100,L2,'r+',1:100,Lf,'bo');
h = legend('Raw Costas Discriminator','Filtered Output',2);
set(h,'Interpreter','none');
title(['Discriminator Output Before and After Applying Filter Using Filter' ...
    ' Equivalent Noise Bandwidth of ', num2str(B),' Hz']); 
xlabel('Time (ms)'); ylabel('Costas Discriminator #2');


