% CASamples.m
% Description:  Decimates a specified number of periods of CA Code
%               according to a specified sampling frequency and PRN
% Inputs:       Number of periods of code,m; sampling frequency, fs; PRN 
%               for desired satellite code; Doppler frequency, fd; and 
%               plot, set to 1 if a plot of the correlations is desired
% Outputs:      The sampled CA code and plots of the generated CA Code
%               and the sampled CA Code
% Date:         02/08/2011
% Modified:     02/18/2011
% Creator:      Jared Morell

function samples=CASamples(m,fs,PRN,fd,plot)

% Constants and variables
fc = 1.023e6;           % chip rate (Hz)
fL1 = 1.57542e9;        % L1 band carrier frequency (Hz)
fc = fc*(1+fd/fL1);     % Doppler shifted chip rate (Hz)
T = 1e-3;               % CA code period (s)
tc = 1/fc;              % chipping period (s)
ts = 1/fs;              % sampling period (s)
numSamps = m*fs*T;      % number of samples
t = ts*(0:numSamps-1);  % time vector (s)

% Convert CA Gold Code array to code samples
code = CACode(PRN);         % get Gold code
code(find(code==0))=-1;     % set 0's to -1's
nc = floor(t/tc) + 1;       % map time to code index
nc_m = rem((nc-1),1023) + 1;% map code index to code period
samples = code(nc_m);       % sampled CA code

% Plot code and sampled code if 'plot' set to 1
if(plot==1)
x1=0:T/1023:T-T/1023;
figure(1);
subplot(2,1,1); plot(x1,code,'r');
title('One Period of Generated CA Code'); xlabel('Time (s)'); ylabel('Code Value');
subplot(2,1,2); plot(t,samples,'g');
title('Sampled CA Code'); xlabel('Time (s)'); ylabel('Code Value');
end


