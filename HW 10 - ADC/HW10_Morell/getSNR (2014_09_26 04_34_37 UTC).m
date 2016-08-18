% getSNR.m
% Description:  Calculates the signal to noise ratio for the given signal
%               spectrum
% Inputs:       xf, signal spectrum
% Outputs:      SNR, signal-to-noise ratio
% Date:         03/16/2011
% Modified:     N/A
% Creator:      Jared Morell with reference to Jade Morton's code

function SNR = getSNR(xf)

n = length(xf);         % number of samples in signal
[amp ind] = max(xf);    % determines peak value of spectrum
PN = (sum(abs(xf).^2)-2*abs(amp)^2)/(n-2);  % noise power
PS = abs(amp)^2;        % signal power

SNR = 10*log10(PS/PN);