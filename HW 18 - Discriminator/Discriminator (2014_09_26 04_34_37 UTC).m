% Discriminator.m
% Description:  Derives the relationship between a discriminator used in
%               code tracking loop and delay time, tau
% Outputs:      Relationship
% Date:         05/01/2011
% Modified:     N/A
% Creator:      Jared Morell



% Early correlator output
Ze = A*D*T1*exp(j*phi0-j*delta_wd*tau)*R(tau-d) + Ne;

% Late correlator output
Zl = A*D*T1*exp(j*phi0-j*delta_wd*tau)*R(tau+d) + Nl;

% Compute normalized early minus late envelope discriminator
disc = (abs(Ze) - abs(Zl))/(abs(Ze) + abs(Zl)); 