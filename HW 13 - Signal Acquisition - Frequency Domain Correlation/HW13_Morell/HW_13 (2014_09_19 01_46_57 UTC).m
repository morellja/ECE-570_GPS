% HW_13.m
% Main program for time- and frequency-domain acquisition

clc
clear all
close all

PRN = 21;
f0 = 1.25e6;                    
fs = 5e6; ts=1/fs;

% Read input data and downconvert to baseband
fileName='g072602f.dat';  
fid=fopen(fileName,'r');
xm=fread(fid,'schar');  
fclose(fid);
ns = length(xm);  
xb = xm'.*exp(-j*2*pi*f0*ts*[0:ns-1]);

% Acquisition in time domain
[acqfd1 acqno1 acqSNR1] = acqTD(PRN, fs, xb);

% Acquisition in frequency domain
[acqfd2 acqno2 acqSNR2] = acqFD(PRN, fs, xb);