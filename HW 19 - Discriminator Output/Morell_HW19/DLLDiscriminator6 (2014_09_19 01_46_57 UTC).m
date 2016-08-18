% DLLDiscriminator6.m
% Description:  Computes DLL discriminator number 6 value
% Inputs:       xTI, signal data during TI integration time
%               PRN, PRN for desired satellite code
%               fs, sampling frequency, Hz
%               fd, Doppler frequency, Hz
%               n0, code phase
%               nd, correlator spacing, number of samples
%               TI, integration time, ms
% Outputs:      L6, DLL discriminator value
% Date:         02/08/2011
% Modified:     05/01/2011 (Jared Morell)
% Author:       Jade Morton

function [L6] = DLLDiscriminator6(xTI, PRN, fs, fd, n0, nd, TI)

nTI = TI*fs*1e-3;   % Number of samples in one integration period

Code = CASamples(TI*10^(-3),fs,fd,PRN);              
CP = [Code(nTI-n0+2:nTI) Code(1:nTI-n0+1)];   
CE = [CP(nd+1:nTI) CP(1:nd)];                 
CL = [CP(nTI-nd+1:nTI) CP(1:nTI-nd)];         

% Early, prompt and late code correlators
ZP = sum(xTI.*CP)/nTI;                        
ZE = sum(xTI.*CE)/nTI;                        
ZL = sum(xTI.*CL)/nTI;     

% #6 discriminator
L6 = (abs(ZE)-abs(ZL))/abs(ZP);