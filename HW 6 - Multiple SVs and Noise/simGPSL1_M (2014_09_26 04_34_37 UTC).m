% simGPSL1_M.m
% Description:  Generates samples for multiple GPS L1 satellites and noise.
%               Navigation data is treated as random binary code sequence.
% Inputs:       L: data length (s)
%               fs: sampling frequency (Hz)
%               nADC: ADC bit number
%               PRN: satellite ID array
%               CN0: carrier to noise ratio array (dB)
%               TK: equivalent noise temperature (K)
%               fIF: carrier frequency (Hz)
%               n0: CA code phase index array
%               phi: carrier phase array (rad)
%               fd: carrier Doppler frequency array (Hz)
%               noiseFlag: noise flag
%               navFlag: navigation data flag
% Outputs:      signal
% Date:         02/23/2011
% Modified:     N/A
% Creator:      Jared Morell

% function signal = simGPSL1_M()

% input parameters
L = 0.020;      % data length (s)
fs = 5e6;       % sampling frequency (Hz)
nADC = 4;       % ADC bit number
PRN = 1;        % satellite ID array
CN0 = 49;       % carrier to noise ratio array (dB)
TK = 535;       % equivalent noise temperature (K)
fIF = 1.25e6;   % carrier frequency (Hz)
n0 = 4;         % CA code phase index array
phi = 0;        % carrier phase array (rad)
fd = 0;         % carrier Doppler frequency array (Hz)
noiseFlag = 0;  % noise flag
navFlag = 0;    % navigation data flag

% constants and variables
k = 1.38e-23;   % Boltzman constant (J/K)
fL1 = 1.57542e9;% L1 band carrier frequency (Hz)
fc0 = 1.023e6;  % CA code chipping rate (Hz)

numSat = length(PRN);   % number of SVs
m = L/0.001;    % number of CA code periods
ts = 1/fs;      % sample interval (s)
Ns = L*fs;      % total number of samples
N = Ns/m;       % number of samples in one code period
n = [1:Ns];     % sample index vector
t = ts*(n-1);   % time vector (s)
fc = fc0(1+fd/fL1); % Doppler adjusted code rate array (Hz)
Pn = k*TK;      % noise power

noise = zeros(1,Ns);    % noise vector
navSamples = ones(1,Ns);% navigation bit vector

% Generate carrier
carrier = cos(2*pi*(fIF+fd)*t+phi);

% Compute amplitude
A = sqrt(2*Pn)*10^(CN0/20);

% Generate navigation data samples
if navFlag==1
    navSamples = navBitsSamples(L,fs,fd);
end

% Generate CA code samples
CA = CASamples(m,fs,PRN,fd);

% Shift the CA code phase
CA = CA.*navSamples;
icp = Ns - n0 + 2;  % initial code phase
CA_shift = [CA(icp:Ns) CA(1:Ns-n0+1)];

% Generate noise samples
if noiseFlag == 1
    noise = sqrt(Pn)*randn(numSat,Ns);
end

% Put the signal together
x = A*CA_shift.*carrier + noise;

% Scale outputs to nADC bits range
maxX = max(abs(x));
x = round(x*2^(nADC-1)/maxX);

% Write to output data file
fid = fopen('simGPSL1_1.dat','wb');
fwrite(fid,x,'schar');
fclose(fid);




