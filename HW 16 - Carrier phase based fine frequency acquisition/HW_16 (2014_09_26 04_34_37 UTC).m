% Test program for carrier phase based fine frequency acquisition

clc
clear all
close all

PRN = [4 7 10 15];% PRN for desired SV
noSV = length(PRN);
f0 = 1.25e6;        % output frequency (Hz)
fs = 5e6;           % sampling frequency (Hz)
ts = 1/fs;          % sampling interval (s)
L = 2e-3;           % data length of 10 ms
ns1 = fs*1e-3;      % number of samples in 1 code period (1ms)

% Read input data and downconvert to baseband
fileName = 'simGPSL1_M_2ms.dat';  
fid = fopen(fileName,'r');
xm = fread(fid,'schar');  
fclose(fid);
ns = length(xm);  % number of samples in signal from data file
xb = xm'.*exp(-j*2*pi*f0*ts*[0:ns-1]);  % baseband signal

for ii = 1:noSV

    % get coarse Doppler frequency and code phase
    [fc n0 acqSNR] = acqFD_NEW(PRN(ii),fs,xb);

    % wipe the code from signal
    x_in = xb(1:2*ns1);                 % 2 ms of data from input data signal
    icp = 2*ns1 - n0 + 2;                           % icp of signal
    code_ref = CASamples(0.002, fs, fc, PRN(ii));   % CA code reference signal
    code_ref = [code_ref(icp:length(code_ref)), code_ref(1:icp-1)]; % start code at icp
    x = code_ref.*x_in;                             % continuous wave signal

    % wipe the coarse Doppler from the signal
    s = exp(-j*2*pi*fc*ts*[0:2*ns1-1]);    % generate sinusoid with coarse Doppler frequency
    x = x.*s;

    % split signal into 2-1 ms segments and carry out fine acquisition
    x1 = x(1:ns1);          % 1st ms of data from wiped signal
    xf1 = fft(x1);
    x2 = x(ns1+1:2*ns1);    % 2nd ms of data from wiped signal
    xf2 = fft(x2);

    [pk1 i1]=max(abs(xf1)); % peak of mag. spectrum of x1
    [pk2 i2]=max(abs(xf2)); % peak of mag. spectrum of x2

    phi1 = atan2(imag(xf1(i1)), real(xf1(i1))); % initial carrier phase of peak in x1
    phi2 = atan2(imag(xf2(i2)), real(xf2(i2))); % initial carrier phase of peak in x2

    dphi = phi2 - phi1; % difference in initial carrier phases
    if dphi > pi
       dphi = dphi - 2*pi;
    elseif dphi < -pi
       dphi = dphi + 2*pi;
    end

    fFine = (dphi)/(ns1*ts*2*pi);   % fine frequency
    fdAcq = fc+fFine;               % acquired fine Doppler frequency

    % disp(['True Doppler: ' num2str( fd)]);
    disp(['Code phase index for PRN ', num2str(PRN(ii)),': ' num2str(n0)]);
    disp(['Coarse Doppler for PRN ', num2str(PRN(ii)),': ' num2str(fc)]);
    disp(['Fine freq for PRN ', num2str(PRN(ii)),': ' num2str(fFine)]);
    disp(['Acquired Doppler for PRN ', num2str(PRN(ii)),': ', num2str(fdAcq)]);
    disp(' ');

end


