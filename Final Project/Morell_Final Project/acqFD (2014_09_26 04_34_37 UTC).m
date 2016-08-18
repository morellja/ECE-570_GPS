% acqTD.m
% Description:  Generates a simulated received GPS L1 band signal for  
%               multiple satellites
% Inputs:       PRN, SV PRN
%               fs, sampling frequency
%               x, signal (baseband down-converted)
% Outputs:      acqfd, acquired Doppler frequency
%               acqn0, acquired code phase
%               acqSNR, estimation of acquired signal SNR
% Date:         04/11/2011 (Jade Morton)

function [acqfd acqn0 acqSNR] = acqFD(PRN,fs,x)

ts = 1/fs;      % sample interval (s)
ns1 = fs*1e-3;  % number of samples in 1 ms
no_fd = 21; fd_step = 500;  %Number of frequency bins & bin size in Hz

% Acquisition in frequency domain
x1 = x(1:ns1); xb1FT = fft(x1); %FFT on 1 ms of input baseband data.
fdMinIndex = -floor(no_fd/2);
fdMin = fdMinIndex*fd_step;

for ifd = 1:no_fd;
    fd = fdMin + (ifd-1)*fd_step;
    CA_ref = CASamples(0.001,fs,fd,PRN);
    xrFFT = fft(CA_ref.*exp(j*2*pi*fd*ts*[0:ns1-1]));
    z(ifd,:) = ifft(xb1FT.*conj(xrFFT));
end
zmag = abs(z); % Magnitude of z

% Search for peaks in correlation output
[amp rowInd]=max(max(zmag'));        
[amp colInd]=max(max(zmag));          
acqfd = fdMin + (rowInd -1)*fd_step; 
acqn0 = colInd;                        
zCode = zmag(rowInd,:);              
zFreq = zmag(:,colInd);   

% Estiamte acquired signal SNR
sigPwr = (zmag(rowInd,colInd)^2+zmag(rowInd,colInd-1)^2+...
    zmag(rowInd,colInd+1)^2);
noisePwr = (sum(sum(zmag.^2))-sigPwr*3)/(ns1*11-3);
acqSNR=10*log10(sigPwr/noisePwr);