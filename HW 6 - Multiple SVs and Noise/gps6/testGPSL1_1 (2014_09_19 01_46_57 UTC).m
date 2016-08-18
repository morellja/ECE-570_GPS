% Script to test GPSL1_1.m civilian signal simulation
clear all 
close all
clc

L = 20; % 20ms is 1 Nav bit period
fs = 5e6; % 5 MHz sampling frequency
nADC = 4; % 4 bit ADC
PRN = 1; % SV ID#
CN0 = 49; % Carrier-to-Noise Ratio (db-Hz)
TK = 535; % Equivalent Temp (Kelvin)
fIF = 1.25e6; % RX IF carrier frequency
n0 = 4; % code phase (sample)
phi = 0; % carrier phase (rad)
fd = 0; % doppler shift (Hz)

% Signal alone (last 2 i/p: 0 Noise,0 Nav)
sig = GPSL1_1(L,fs,nADC,PRN,CN0,TK,fIF,n0,phi,fd,0,0);
sig_PS = fftshift(abs(fft(xcorr(sig,sig))));

fn1 = linspace(-fs/2,fs/2,length(sig_PS));
figure('Name','L1 Civil Signal Power Spectrum');
plot(fn1,10*log10(sig_PS))
xlabel('frequency (Hz)')
ylabel('Power (dB)')

% Signal + Nav Data (last 2 i/p: 0 Noise,1 Nav)
sigNav = GPSL1_1(L,fs,nADC,PRN,CN0,TK,fIF,n0,phi,fd,0,1);
sigNav_PS = fftshift(abs(fft(xcorr(sigNav,sigNav))));

fn2 = linspace(-fs/2,fs/2,length(sigNav_PS));
figure('Name','L1 Civil Signal+NavBits Power Spectrum');
plot(fn2,10*log10(sigNav_PS))
xlabel('frequency (Hz)')
ylabel('Power (dB)')

% Signal + Noise (last 2 i/p: 1 Noise,0 Nav)
sigNoise = GPSL1_1(L,fs,nADC,PRN,CN0,TK,fIF,n0,phi,fd,1,0);
sigNoise_PS = fftshift(abs(fft(xcorr(sigNoise,sigNoise))));

fn3 = linspace(-fs/2,fs/2,length(sigNoise_PS));
figure('Name','L1 Civil Signal+Noise Power Spectrum');
plot(fn3,10*log10(sigNoise_PS))
xlabel('frequency (Hz)')
ylabel('Power (dB)')

% Signal+Noise+Nav (last 2 i/p: 1 Noise,1 Nav)
sigNavNoise = GPSL1_1(L,fs,nADC,PRN,CN0,TK,fIF,n0,phi,fd,1,1);
sigNavNoise_PS = fftshift(abs(fft(xcorr(sigNavNoise,sigNavNoise))));

fn4 = linspace(-fs/2,fs/2,length(sigNavNoise_PS));
figure('Name','L1 Civil Signal+Noise+NavBits Power Spectrum');
plot(fn4,10*log10(sigNavNoise_PS))
xlabel('frequency (Hz)')
ylabel('Power (dB)')