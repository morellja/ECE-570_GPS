% probDet.m
% Description:  Calculates the probability of detection for a system given
%               user inputs
% Inputs:       Pfa, probability of false alarm
%               sigma, RMS value of noise power
%               T, dwell time (s)
%               CN0, carrier-to-noise ratio (dB-Hz)
% Outputs:      Vt, threshold value of system
%               Pd, probability of detection
% Date:         04/11/2011
% Modified:     N/A
% Author:       Jared Morell

function [Vt Pd] = probDet(Pfa, sigma, CN0, T)

B = 1/T;
theta = 0:1/(2*B):10;
z = 0:1/(2*B):10;

% Calculate threshold value for system
Vt = sigma*sqrt(-2*log(Pfa));

% Calculate SNR
SNR_dB = CN0 + 10*log10(T); % dB
SNR = 10*log10(SNR_dB/10);

% Calculate zero-order Bessel function and, from that, the probability of
% detection
for j = 0:Vt/1000:Vt
    for k = 0:pi/1000:pi
        I0 = 1/pi*exp(u*cos(theta)) + I0; % ???????
    end
    Pd = z/sigma^2*exp(-1*(z^2/(2*sigma^2)+SNR))*I0*(z/sigma*sqrt(2*SNR) + Pd; % ???
end