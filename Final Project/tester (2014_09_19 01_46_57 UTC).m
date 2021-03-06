% GPS_Acq_and_Track.m
% Description:  Main program for acquiring and tracking GPS signals

clc
clear all
close all

%----------------------------
% Constants and variables
%----------------------------

% Inputs
f0 = 1.25e6;        % ADC output center (Hz)
fs = 5e6;           % Sampling frequency (Hz)
ts = 1/fs;
TI = 0.001;         % Integration time (s)
nTI = TI*fs;        % Number of samples in integration time
nd = 2;             % Correlator spacing (samples) btw early-prompt, prompt-late
B = 5;              % Filter equivalent noise bandwidth, Hz
PRN = [4 7 7 15];  % SV IDs
noSV = length(PRN); % number of SVs
phi = zeros(noSV,1);% carrier phase, degrees

% PLL parameters
a2 = 1.4;           % Damping factor;
wn = B*4/(a2+1/a2);

% Bilinear transformation transfer function coefficients
wnTI = wn*TI; wnTI2 = (wnTI)^2; wnTIa2 = wnTI*a2*2;
b0 = wnTI2 + wnTIa2;
b1 = 2*wnTI2;
b2 = wnTI2 - wnTIa2;
d0 = wnTI2 + wnTIa2 + 4;
d1 = 2*wnTI - 8;
d2 = wnTI2 - wnTIa2 + 4;

%-----------------------
% Begin program
%-----------------------

% Read input data and downconvert to baseband
fileName = 'simGPSL1_1sec_Nav.dat';  
fid = fopen(fileName,'r');
xm = fread(fid,'schar');  
fclose(fid);
ns = length(xm);  % number of samples in signal from data file
xb = xm'.*exp(-j*2*pi*f0*ts*[0:ns-1]);  % baseband signal

% Coarse and fine acquisition
[n0Acq(3) fdAcq(3)] = Acquisition(xb, PRN(3), fs, 0.002);

% DLL and PLL output variables
nBlocks = floor(ns/nTI);        % number of 1 ms blocks of data
L = zeros(noSV, nBlocks);
Lp = zeros(noSV, nBlocks);
L2 = zeros(noSV, nBlocks);
Lf = zeros(noSV, nBlocks);
Zp = zeros(noSV, nBlocks);

%---------------------
% 1st millisecond
%---------------------

% Wipe Doppler frequency from 1st ms
x_in = xb(1:nTI);                       % 1 ms of data from input data signal
s = exp(-j*2*pi*fdAcq(3)*ts*[0:nTI-1]); % generate sinusoid with coarse Doppler frequency
xTI = x_in.*s;                          % Doppler wiped

% Compute DLL discriminator output for 1st ms
L(3,1) = DLLDiscriminator6(xTI, PRN(3), fs, fdAcq(3), n0Acq(3), nd, TI);
Lp(3,1) = L(3,1);

% Compute updated code phase index
n0Acq(3) = round(n0Acq(3) + Lp(3,1));

% Wipe code
icp = nTI - n0Acq(3) + 2;               % icp of signal
code_ref = CASamples(0.001, fs, fdAcq(3), PRN(3));   % CA code reference signal
code_ref = [code_ref(icp:length(code_ref)), code_ref(1:icp-1)]; % start code at icp
xTI = code_ref.*xTI;                    % code wiped

% Compute PLL discriminator output for 1st ms
Code = CASamples(TI,fs,fdAcq(3),PRN(3));
CP = [Code(nTI-n0Acq(3)+2:nTI) Code(1:nTI-n0Acq(3)+1)];
[L2(3,1),Zp(3,1)] = CostasDiscriminator2(xTI,CP);
Lf(3,1) = L2(3,1);

% Compute updated carrier phase
phi(3) = phi(3)+Lf(3,1);

%---------------------
% 2nd millisecond
%---------------------

% Wipe Doppler frequency
x_in = xb(nTI+1:2*nTI);                 % 2nd ms of data from input data signal
s = exp(-j*2*pi*fdAcq(3)*ts*[nTI:2*nTI-1]-j*phi(3)); % generate sinusoid with coarse Doppler frequency
xTI = x_in.*s;                          % Doppler wiped

% Compute DLL discriminator output
L(3,2) = DLLDiscriminator6(xTI, PRN(3), fs, fdAcq(3), n0Acq(3), nd, TI);
Lp(3,2) = Lp(3,1) + TI*4*B*(L(3,2)-Lp(3,1));

% Compute updated code phase index
n0Acq(3) = round(n0Acq(3) + Lp(3,2));

% Wipe code
icp = nTI - n0Acq(3) + 2;               % icp of signal
code_ref = CASamples(0.001, fs, fdAcq(3), PRN(3));   % CA code reference signal
code_ref = [code_ref(icp:length(code_ref)), code_ref(1:icp-1)]; % start code at icp
xTI = code_ref.*xTI;                    % code wiped

% Compute PLL discriminator output
Code = CASamples(TI,fs,fdAcq(3),PRN(3));
CP = [Code(nTI-n0Acq(3)+2:nTI) Code(1:nTI-n0Acq(3)+1)];
[L2(3,2),Zp(3,2)] = CostasDiscriminator2(xTI,CP);
Lf(3,2) = L2(3,2);

% Compute updated carrier phase
phi(3) = phi(3)+Lf(3,2);

%-------------------------
% Compute rest of data
%-------------------------

% ii is the millisecond (block) index
for ii = 3:nBlocks
    % Wipe Doppler frequency
    x_in = xb((ii-1)*nTI+1:ii*nTI);         % ms of data from input data signal
    s = exp(-j*2*pi*fdAcq(3)*ts*[(ii-1)*nTI:ii*nTI-1]-j*phi(3)); % generate sinusoid with coarse Doppler frequency
    xTI = x_in.*s;                          % Doppler wiped
    
    % Compute DLL discriminator output
    L(3,ii) = DLLDiscriminator6(xTI, PRN(3), fs, fdAcq(3), n0Acq(3), nd, TI);
    Lp(3,ii) = Lp(3,ii-1) + TI*4*B*(L(3,ii)-Lp(3,ii-1));
    
    % Compute updated code phase index
    n0Acq(3) = round(n0Acq(3) + Lp(3,ii));
    
    % Wipe code
    icp = nTI - n0Acq(3) + 2;               % icp of signal
    code_ref = CASamples(0.001, fs, fdAcq(3), PRN(3));   % CA code reference signal
    code_ref = [code_ref(icp:length(code_ref)), code_ref(1:icp-1)]; % start code at icp
    xTI = code_ref.*xTI;                    % code wiped
    
    % Compute PLL discriminator output
    Code = CASamples(TI,fs,fdAcq(3),PRN(3));
    CP = [Code(nTI-n0Acq(3)+2:nTI) Code(1:nTI-n0Acq(3)+1)];
    [L2(3,ii), Zp(3,ii)] = CostasDiscriminator2(xTI, CP);
    Lf(3,ii)=(b0*L2(3,ii)+b1*L2(3,ii-1)+b2*L2(3,ii-2)-d1*Lf(3,ii-1)- ...
        d2*Lf(3,ii-2))/d0;
    
    % Compute updated carrier phase
    phi(3) = phi(3)+Lf(3,ii);
    
    
end

%----------------------
% Plot Results
%----------------------

% DLL Discriminator
figure();
plot(1:nBlocks,L(3,:),'r+',1:nBlocks,Lp(3,:),'bo');
h = legend('Raw Discriminator','Filtered Output',2);
set(h,'Interpreter','none');
title('DLL Discriminator Output Before and After Applying Filter'); 
xlabel('Time (ms)'); ylabel('DLL Discriminator #6');

figure();
plot(1:nBlocks,L2(3,:),'r+',1:nBlocks,Lf(3,:),'bo');
h = legend('Raw Costas Discriminator','Filtered Output',2);
set(h,'Interpreter','none');
title('PLL Discriminator Output Before and After Applying Filter'); 
xlabel('Time (ms)'); ylabel('Costas Discriminator #2');

figure();
plot(1:nBlocks,Zp(3,:),'r+');
title('Navigation Data'); 
xlabel('Time (ms)'); ylabel('Data Bits');



%end