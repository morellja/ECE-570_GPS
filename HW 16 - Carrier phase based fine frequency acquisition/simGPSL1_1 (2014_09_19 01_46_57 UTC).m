% Program Name: simGPSL1_1.m
% Description:  Simulates GPS L1 signal for a single satellite
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
% Output:       x,      	simulated output
% Programmer:   Dr. Jade Morton
% Date Written: N/A
% Date Modified:4/1/2011

function[x] = simGPSL1_1(L, fs, f0, nADC, B, PRN, CN0, n0, phi, fd, noiseFlag, navFlag)
fc= 1.023e6;            % L1 CA code chipping rate in Hz
fL1 = 1.57542e9;        % L1 carrier frequency in Hz
ts= 1/fs;               % Sample interval (s)
ns1 = 1e-3*fs;          % Sample # in one code period.
ns = L*fs;              % Total number of samples
fc= fc*(1+fd/fL1);      % Effective code rate in Hz
tc= 1/fc;               % Effective code chip length
k=1.38e-23;             % Boltzman constant
TK=535;                 % Equivalent noise temperature in Kelvin
Pn=k*TK;                % Noise power density

% Generate GPS Signal
A = sqrt(2*Pn)*10^(CN0/20); % Signal amplitude
CA = CASamples(L, fs, fd, PRN); % CA code samples

if(navFlag== 1)
    CA = CA .* navBitsSamples(L, fs, fd); % Add Navdata modulation
end

icp= ns -n0 + 2; CA_shift=[CA(icp:ns) CA(1:ns-n0+1)];% Shift CA code to desired phase
x = A*CA_shift.*cos(2*pi*(f0+fd)*ts*[0:ns-1] + phi);% Complete signal sequence

% Add thermal noise if desired.
if(noiseFlag== 1)
    noise = sqrt(B*Pn)*randn(1, ns); x = x+noise;
end;

% Scale the output to the range of a fully exercised nADCbits
maxX= max(abs(x)); x = x * 2^(nADC-1)/ maxX; x = round(x);