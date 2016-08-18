% crossCorr.m
% Description:  circular cross-correlation between two signals
% Inputs:       two signals to be correlated, s1 and s2 (must be of same
%               length)
% Outputs:      cross-correlation between s1 and s2
% Date:         02/24/2011
% Modified:     N/A
% Creator:      Jared Morell

function cross = crossCorr(s1,s2)

len=length(s1);
cross=zeros(1,len); % cross-correlation of s1 and s2
i=1;
while(i<len+1)
    s1Shift=[s1(i:len) s1(1:i-1)];
    cross(i) = sum(s1Shift.*s2);      
    i=i+1;
end