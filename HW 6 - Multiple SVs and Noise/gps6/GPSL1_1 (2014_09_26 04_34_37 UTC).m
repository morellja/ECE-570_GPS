% Program Name:   simGPSL1_1.m (Assignment 6 simplified)
% Description:    DO NOT TURN IN
%                 Algorithm for One SV Signal Generation
% Inputs:         Sattelite ID PRN#
%                 Data Length L (ms)
%                 Sampling frequency fs (Hz)
%                 ADC bit number nADC
%                 SV ID# PRN
%                 Carrier to Noise Ratio CN0 (dB-Hz)
%                 Equivalent Noise Temperature TK (K)
%                 Carrier frequency fIF (Hz)
%                 CA code phase n0 (sample index)
%                 Carrier phase phi (rad)
%                 Carrier Doppler Frequency fd (Hz)
%                 Noise Flag
%                 Nav Bit Flag
% Output:         sig: L1 civilian signal for 1 sattelite
%                 output data file 'simGPSL1_1.dat'
% Programmer:     Aaron Curtis
% Date Created:   2/21/2011
% Last Mod Date:  N/A

function sig = GPSL1_1(L,fs,nADC,PRN,CN0,TK,fIF,n0,phi,fd,noiseFlag,navFlag)

% Constants and Vectors

k = 1.38e-23; % Boltzman Constant (J/K)
fL1 = 1.57542e9; % 1.57542 GHz L1 Signal Carrier frequency
fc0 = 1.023e6; % initial chipping rate (1.023 MHz)


ts = 1/fs; % sample interval (sec)
Ns = L*fs/1000; % total number of output samples
n = [1:Ns]; % sample index vector
t = ts*(n-1); % time vector

Pn = k*TK; % noise power

noise = zeros(1,Ns); % noise vector
navSamples = ones(1,Ns); % nav bit vector

% Generate Carrier Signal
carrier = cos(2*pi*(fIF+fd)*t+phi);

% Amplitude Computation
A = sqrt(2*Pn)*10^(CN0/20);

% Generate Nav Data Samples
if navFlag == 1
    navSamples = navBitsSamples(L,fs,fd);
end

% Generate CA Code Samples
CA = CASamples(L,fs,PRN,fd);

% Shift Code Phase
CA = CA.*navSamples;
icp = Ns - n0 + 2;
CA_shift = [CA(icp:Ns) CA(1:Ns-n0+1)];

% Generate Noise Samples
if noiseFlag == 1
    noise = sqrt(Pn)*randn(1,Ns);
end

% Assemble Signal
x = A * CA_shift .* carrier + noise;

% Scale outputs to nADC bits range
maxX = max(abs(x));
x = round(x*2^(nADC-1)/maxX);

% Output Data File
fid = fopen('simGPSL1_1.dat','wb');
fwrite(fid,x,'schar');
fclose(fid);

sig = x;