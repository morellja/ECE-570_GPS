% CACode_Correlation.m
% Description:  Computes the CA code cross-correlation between two
%               specified PRNs and the auto-correlation of one PRN CA code
% Inputs:       2 PRN's to be cross-correlated, the first of which will
%               also undergo auto-correlation; sampling frequency, fs
% Outputs:      Plotted results of the cross- and auto-correlation
% Date:         02/18/2011
% Modified:     N/A
% Creator:      Jared Morell

function corr=CACode_Correlation(PRN1,PRN2)

fs = 5e6;   % sampling frequency
fd1 = 0;    % Doppler frequency of PRN1
fd2 = 0;    % Doppler frequency of PRN2

% Generate both PRNs' CA Code
corr.code1 = CASamples(1,fs,PRN1,fd1,0); 
corr.code2 = CASamples(1,fs,PRN2,fd2,0);

corr.cross = crossCorr(corr.code1,corr.code2); % cross-correlation of the two codes
corr.auto = crossCorr(corr.code1,corr.code1);  % auto-correlation of the 1st code

% Plot results
len=length(corr.cross);
x = 0:len-1;      % samples vector
figure;
subplot(2,1,1); plot(x,corr.cross,'r');
title(['Cross-Correlation between PRN ',num2str(PRN1),' and PRN ',num2str(PRN2)]); 
xlabel('Index'); ylabel('Correlation Value');
subplot(2,1,2); plot(x,corr.auto,'g');
title(['Auto-Correlation of PRN ',num2str(PRN1)]); 
xlabel('Index'); ylabel('Correlation Value');

