% acqTD.m
% Description:  Generates a simulated received GPS L1 band signal for  
%               multiple satellites
% Inputs:       PRN, SV PRN
%               fs, sampling frequency
%               x, signal (baseband down-converted)
% Outputs:      acqfd, acquired Doppler frequency
%               acqn0, acquired code phase
%               acqSNR, estimation of acquired signal SNR
% Date:         02/18/2011 (Jade Morton)
% Modified:     04/11/2011 (Jared Morell)

function [acqfd acqn0 acqSNR] = acqTD(PRN,fs,x)

ts = 1/fs;      % sample interval (s)
ns1 = fs*1e-3;  % number of samples in 1 ms
no_fd = 11;     % number of frequency bins
fd_step = 1000; % bin size (Hz)

% Correlation between input and reference signal

fdMinIndex = -floor(no_fd/2); 
fdMin = fdMinIndex*fd_step;

for ifd = 1:11
    fd = fdMin + (ifd-1)*fd_step;
    CA_ref = CASamples(0.001,fs,fd,PRN);     
    carrier_ref = exp(-2*j*pi*fd*ts*[0:ns1-1]);
    sig_ref = CA_ref.* carrier_ref;
    z(ifd,:)= crossCorr(sig_ref, x(1:ns1));
end
zmag = abs(z);

% Search for peak correlation
[amp rowInd]=max(max(zmag'));       
[amp colInd]=max(max(zmag));            
acqfd = -5000 + (rowInd -1)*1000;  
acqn0 = ns1 - colInd + 2;               
zCode = zmag(rowInd,:);        
zFreq = zmag(:,colInd);

% Estiamte acquired signal SNR
sigPwr = zmag(rowInd,colInd)^2+zmag(rowInd,colInd-1)^2+...
    zmag(rowInd,colInd+1)^2;
noisePwr = (sum(sum(zmag.^2))-sigPwr)/(ns1*11-3);
acqSNR=10*log10(sigPwr/noisePwr);
