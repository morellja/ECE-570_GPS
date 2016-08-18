% Acquisition.m
% Description:  Perform coarse and fine Doppler frequency acquisition and
%               code phase acquisition on baseband signal
% Inputs:       xb, baseband signal
%               PRN, SV IDs (array)
%               fs, sampling frequency, Hz
%               L, data length (s)

function [n0Acq fdAcq] = Acquisition(xb, PRN, fs, L)

noSV = length(PRN); % number of satellites in PRN array
ts = 1/fs;          % sampling interval (s)
ns1 = fs*1e-3;      % number of samples in 1 code period (1ms)
ns = L*10^3*ns1;    % total number of samples in data

for ii = 1:noSV

    % get coarse Doppler frequency and code phase
    [fc n0Acq(ii) acqSNR] = acqFD(PRN(ii),fs,xb);

    % wipe the code from signal
    x_in = xb(1:2*ns1);                 % 2 ms of data from input data signal
    icp = 2*ns1 - n0Acq(ii) + 2;                    % icp of signal
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

    dphi = phi1 - phi2; % difference in initial carrier phases
    if dphi > pi
       dphi = dphi - 2*pi;
    elseif dphi < -pi
       dphi = dphi + 2*pi;
    end

    fFine = (dphi)/(ns1*ts*2*pi);   % fine frequency
    fdAcq(ii) = fc+fFine;           % acquired fine Doppler frequency

end


