% Corrs_Discrims.m
% Description:  Computes early, prompt, and late correlations and DLL
%               discriminators (all 6)
% Inputs:       f0, ADC output center frequency, Hz
%               fs, sampling frequency, Hz               
%               TI, integration time, ms
%               nd, correlator spacing, number of samples
%               PRN, PRN for desired satellite code 
%               fdEst, estimated Doppler frequency, Hz
%               n0Est, estimated code phase
% Outputs:      Code correlators and DLL discriminators
% Date:         02/08/2011
% Modified:     05/01/2011 (Jared Morell)
% Author:       Jade Morton

f0 = 1.25e6;        % ADC output center (Hz)
fs = 5e6;           % Sampling frequency (Hz)
TI = 1;             % Integration time (ms)
nTI = TI*fs*1e-3;   % Number of samples in integration time
nd = 2;     % Correlator spacing (samples) btw early-prompt, prompt-late

% Assume perfect knowledge of Doppler
PRN = 10; 
fdEst = 2200;   % estimated Doppler (Hz)
n0Est = 2500;   % estimated code phase

% Read signal from data file and save to 'x'
fid = fopen('simGPSL1_4SVs_10ms.dat','r'); 
x = fread(fid,'schar'); 
fclose(fid);

Code = CASamples(TI*10^(-3),fs,fdEst,PRN);% Reference code generation
n0Trk = n0Est-4; % Code phase from prior estimation
for ii = 1:9
    % Down convert input to baseband
    xb=x(1:nTI)'.*exp(-j*2*pi*(f0+fdEst)*[0:nTI-1]/fs);
    
    CP=[Code(nTI-n0Trk+2:nTI) Code(1:nTI-n0Trk+1)]; % Prompt code
    CE=[CP(nd+1:nTI) CP(1:nd)];                     % Early code
    CL=[CP(nTI-nd+1:nTI) CP(1:nTI-nd)];             % Late code
    
    % Code Correlators
    ZP = sum(xb.*CP)/nTI; 
    ZE = sum(xb.*CE)/nTI; 
    ZL = sum(xb.*CL)/nTI;
    
    % DLL Discriminators
    L1(ii)=ZE-ZL;
    L2(ii)=(abs(ZE)^2-abs(ZL)^2);
    L3(ii)=(abs(ZE)-abs(ZL));
    L4(ii)=L3(ii)/(abs(ZE)+abs(ZL));
    L5(ii)=((real(ZE)-real(ZL))*real(ZP)+(imag(ZE)-imag(ZL))*imag(ZP));
    L6(ii)=(abs(ZE)-abs(ZL))/abs(ZP);
    
    n0Trk = n0Trk+1;
end