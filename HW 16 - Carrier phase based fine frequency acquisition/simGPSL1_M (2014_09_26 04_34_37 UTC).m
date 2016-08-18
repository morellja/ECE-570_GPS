% Program Name: simGPSL1_M.m
% Description:  Simulates GPS L1 signal for multiple satellites
% Inputs:       L,          code length, in seconds
%               fs,         sampling frequency
%               f0,         ADC output center frequency in MHz
%               nADC,       ADC bit number
%               B,          Front end bandwidth in Hz
%               PRN,        user specified GPS SV ID
%               CN0,        carrier to noise ration in dB-Hz
%               n0,         initial code pahse index
%               phi,        carrier phase in radians
%               fd,         carrier doppler frequency in Hz
%               noiseFlag,  1--add noise; 0--do not add noise
%               navFlag,    1--add navigation data bit; 0--do not add
%                           navigation data bit
% Output:       xm,      	simulated output
% Programmer:   Dr. Jade Morton
% Date Written: N/A
% Date Modified:4/1/2011

function [xm] = simGPSL1_M(L, fs, f0, nADC, B, PRN, CN0, n0, phi, fd, noiseFlag, navFlag)
fc= 1.023e6;            % L1 CA code chipping rate in Hz
fL1 = 1.57542e9;        % L1 carrier frequency in Hz
ts= 1/fs;               % Sample interval (s)
ns1 = 1e-3*fs;          % Sample # in one code period.
ns = L*fs;              % Total number of samples
n = [0:ns-1];           % Sample index array
fc= fc*(1+fd/fL1);      % Effective code rate in Hz (array)
tc= 1./fc;              % Effective code chip length (array)
noSV= length(PRN);
A = sqrt(2)*10.^(CN0/20); % Signal amplitude (array)

for ii = 1: noSV
    CA(ii,:) = CASamples(L,fs,fd(ii),PRN(ii));
    if (navFlag== 1)
        CA(ii,:) = CA(ii,:).* navBitsSamples(L,fs,fd(ii));
    end
    icp = ns -n0(ii) + 2; CA_shift(ii,:) =[CA(ii,icp:ns) CA(ii,1:ns-n0(ii)+1)];
    x(ii,:) = A(ii)*CA_shift(ii,:).*cos(2*pi*(f0+fd(ii))*ts*n + phi(ii));
end

if (noiseFlag== 1); noise = sqrt(B)*randn(1, ns); xm= sum(x,1)+noise; end;
maxX= max(abs(xm)); xm= xm* 2^(nADC-1)/ maxX; xm= round(xm);