% CostasDiscriminator2.m
% Description:  Computes the raw Costas discriminator and its filtered
%               output
% Inputs:       xTI, signal over TI integration time
%               CP, prompt code
% Outputs:      L, discriminator value
%               ZP, prompt correlator output
% Date:         04/26/2011
% Author:       Jade Morton


function [L, ZP] = CostasDiscriminator2(xTI, CP)
    prod=xTI.*CP; % wipe code and carrier off input
    ZP=sum(prod); % Prompt correlator output
    L=atan(imag(ZP)/real(ZP))*180/pi;
    if L>90
        L=L-180;
    end
end