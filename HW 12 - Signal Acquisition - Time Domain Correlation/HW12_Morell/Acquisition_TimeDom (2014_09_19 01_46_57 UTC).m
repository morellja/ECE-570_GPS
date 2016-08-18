% Acquisition_TimeDom.m
% Description:  Generates a simulated received GPS L1 band signal for  
%               multiple satellites
% Inputs:       PRN, SV PRN
% Outputs:      acqfd, acquired Doppler frequency
%               acqn0, acquired code phase
%               acqSNR, estimation of acquired signal SNR
%               procTime, processing time of the program
% Date:         02/18/2011 (Jade Morton)
% Modified:     03/29/2011 (Jared Morell)

clc
clear all
close all

% Start timer to determine processing time
tic;

% User input
PRN = 28;

% RF front end parameters
f0 = 1.25e6;                         % ADC output center frequency in Hz
fs = 5e6; ts = 1/fs; ns1 = fs*1e-3;  % Sampling frequency and associated parameters

% Read input data
fileName = 'gs0_w0.dat';  
fid = fopen(fileName,'r');  
xm = fread(fid,'schar');  
fclose(fid);

% Down convert input to baseband
ns = length(xm);  
xb = xm'.*exp(-j*2*pi*f0*ts*[0:ns-1]);

% Correlation between input and reference signal
for ifd = 1:11
    fd = -5000 + (ifd-1)*1000; 
    carrier_ref = exp(-2*j*pi*fd*ts*[0:ns1-1]);
    CA_ref = CASamples(1e-3, fs, fd, PRN);     
    sig_ref = CA_ref.* carrier_ref;
    z(ifd,:) = crossCorr(sig_ref, xb(1:ns1));
end

% Search for peak correlation and compute acquired Doppler and code phase index
[amp rowInd] = max(max(abs(z')));   
[amp colInd] = max(max(abs(z)));      
acqfd = -5000 + (rowInd -1)*1000   
acqn0 = ns1 - colInd +2     

% Estimate acquired signal SNR
sigPwr = (abs(z(rowInd,colInd))^2+abs(z(rowInd,colInd-1))^2+abs(z(rowInd,colInd+1))^2)/3;
noisePwr = (sum(sum(abs(z.^2)))-sigPwr*3)/(ns1*11-3);
acqSNR = 10*log10(sigPwr/noisePwr)

% Processing time of program
procTime = toc