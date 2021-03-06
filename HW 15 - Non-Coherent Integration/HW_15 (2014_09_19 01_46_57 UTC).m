% HW_15.m
% Main program for coarse acquisition using non-coherent integration

clc
clear all
close all

PRN = 15;           % desired PRN for acquisition
f0 = 1.25e6;        % output frequency (Hz)
fs = 5e6; ts=1/fs;  % sampling frequency (Hz)
M = 10;             % number of non-coherent integrations

% Read input data and downconvert to baseband
fileName = 'g072602f.dat';  
fid = fopen(fileName,'r');
xm = fread(fid,'schar');  
fclose(fid);
ns = length(xm);  % number of samples in signal from data file
xb = xm'.*exp(-j*2*pi*f0*ts*[0:ns-1]);  % baseband signal

% Acquisition using non-coherent integration
[acqfd acqno acqSNR] = nonCoherentInt(PRN, fs, xb, M)
