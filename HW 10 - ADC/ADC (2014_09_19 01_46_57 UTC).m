% ADC.m
% Description:  Calculates the output signal-to-noise ratio for an n-bit 
%               ADC, using a sine function and Gaussian noise
% Inputs:       SNRin, input signal-to-noise ratio
%               fi, input signal frequency
%               fs, sampling frequency
%               a, signal amplitude
%               n, number of bits used to quantize signal
% Outputs:      SNR, signal-to-noise ratio of signal with noise
%               SNRd, signal-to-noise ratio of digitized signal
% Date:         03/16/2011
% Modified:     N/A
% Creator:      Jared Morell

clc
clear all
close all

% inputs
SNRin = -3;     % input SNR, dB
fi = 1.25e6;    % input signal frequency, Hz
fs = 10e6;       % sampling rate, Hz
a = 1;          % signal amplitude, V
n = 4;          % number of bits used to quantize signal

% variables
T = 1/fi;       % input signal period, s
ts = 1/fs;      % time between samples, s
L = 10*T;       % data length, s
ns = fs*L;      % number of samples
df = 1/L;       % differential frequency component, Hz
t = ts*[0:ns-1];% time vector, s
f = df*[0:ns-1];% frequency vector, Hz
vpp = 2*a;      % peak-to-peak voltage of signal, V
delta = vpp/(2^n-1);    % step size of ADC

% Generate a signal, x, consisting of a sine function and Gaussian noise
s = a*sin(2*pi*fi*t);   % sinusoidal signal
noise = randn(1,ns);    % noise
x = s+noise;            % resulting signal
X = fft(x);             % resulting signal spectrum

% Generate n-bit ADC digitized signal
xd = zeros(1,ns);   % digitized signal
count = 0;
diff = delta;
ind = find(x<-a);
xd(ind) = -a;
while(count<vpp/delta+1)
    ind = find(x<-a+diff & x>-a-delta+diff);
    xd(ind) = -a-delta+diff;
    count = count+1;
    diff = diff + delta;
end
ind = find(x>a);
xd(ind) = a;
Xd = fft(xd);   % digitized signal spectrum

% Compute signal-to-noise ratios
SNR = getSNR(X)
SNRd = getSNR(Xd)

% Plot original signal, the signal with noise, and the digitized signal
figure(1);
subplot(3,1,1); plot(t,s,'r*');
title('Original Signal'); xlabel('Time (s)'); ylabel('Amplitude (V)');
subplot(3,1,2); plot(t,x,'g*');
title('Signal with noise'); xlabel('Time (s)'); ylabel('Amplitude (V)');
subplot(3,1,3); plot(t,xd,'b*');
title('Digitized Signal'); xlabel('Time (s)'); ylabel('Amplitude (V)');

% Plot spectrum of signal with noise and spectrum of digitized signal
figure(2);
subplot(2,1,1); plot(f,X,'bo');
title('Signal Spectrum'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
subplot(2,1,2); plot(f,Xd,'go');
title('Digitized Signal Spectrum'); xlabel('Frequency (Hz)'); ylabel('Magnitude');


