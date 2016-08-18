% nonCoherentInt.m
% Description:  Computes acquired signal's carrier Doppler frequency, code
%               phase, and estimated SNR
% Inputs:       PRN, SV PRN
%               fs, sampling frequency
%               x, signal (baseband down-converted)
%               M, number of non-coherent integrations
% Outputs:      acqfd, acquired Doppler frequency
%               acqn0, acquired code phase
%               acqSNR, estimation of acquired signal SNR
% Date:         04/20/2011
% Author:       Jared Morell

function [acqfd acqn0 acqSNR] = nonCoherentInt(PRN,fs,x,M)

ts = 1/fs;      % sample interval (s)
ns1 = fs*1e-3;  % number of samples in 1 ms
no_fd = 11; fd_step = 1000;  %Number of frequency bins & bin size in Hz

% determine minimum Doppler frequency
fdMinIndex = -ceil(no_fd/2);
fdMin = fdMinIndex*fd_step;

% perform coherent integration over M blocks of data
zmagSum = zeros(11,ns1);
for m = 1:M
    start = (m-1)*ns1 + 1;  % start index of data 
    finish = m*ns1;         % last index of data 
    x1 = x(start:finish);   % data block
    xb1FT = fft(x1);        % FFT on 1 ms of input baseband data.
    
    % compute coherent integration on block of data
    for ifd = 1:no_fd;
        fd = fdMin + (ifd-1)*fd_step;
        CA_ref = CASamples(0.001,fs,fd,PRN);
        xrFFT = fft(CA_ref.*exp(j*2*pi*fd*ts*[0:ns1-1]));
        z(ifd,:) = ifft(xb1FT.*conj(xrFFT));
    end
    
    zmag = abs(z);              % Magnitude of z
    
    %figure;
    %plot(1:ns1,zmag(8,:),'r');
    
    zmagSum = zmagSum + zmag;   % sum the magnitudes of each coherent integration
end

% Search for peaks in correlation output
[amp rowInd]=max(max(zmagSum'));        
[amp colInd]=max(max(zmagSum));          
acqfd = fdMin + (rowInd -1)*fd_step; 
acqn0 = colInd;                        
zCode = zmagSum(rowInd,:);              
zFreq = zmagSum(:,colInd);   

% Estimate acquired signal SNR
sigPwr = (zmagSum(rowInd,colInd)^2+zmagSum(rowInd,colInd-1)^2+...
    zmagSum(rowInd,colInd+1)^2);
noisePwr = (sum(sum(zmagSum.^2))-sigPwr*3)/(ns1*11-3);
acqSNR=10*log10(sigPwr/noisePwr);



