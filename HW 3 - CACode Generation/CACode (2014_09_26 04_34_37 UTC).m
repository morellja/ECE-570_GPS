% CACode.m
% Description:  Generates on period of Gold code sequence for a given PRN
% Inputs:       PRN for desired satellite code
% Outputs:      One period of Gold code for desired satellite
% Date:         02/08/2011
% Modified:     N/A
% Creator:      Jared Morell

function code=CACode(PRN)

% Initialize generator registers
G1=[1 1 1 1 1 1 1 1 1 1];
G2=[1 1 1 1 1 1 1 1 1 1];

code=1:1023;    % array containing Gold code

% Determine the G2 phase selection to be used based on the PRN number
switch PRN
    case 1
        phase1 = 2; phase2 = 6;
    case 2
        phase1 = 3; phase2 = 7;
    case 3
        phase1 = 4; phase2 = 8;
    case 4
        phase1 = 5; phase2 = 9;
    case 5
        phase1 = 1; phase2 = 9;
    case 6
        phase1 = 2; phase2 = 10;
    case 7
        phase1 = 1; phase2 = 8;
    case 8
        phase1 = 2; phase2 = 9;
    case 9
        phase1 = 3; phase2 = 10;
    case 10
        phase1 = 2; phase2 = 3;
    case 11
        phase1 = 3; phase2 = 4;
    case 12
        phase1 = 5; phase2 = 6;
    case 13
        phase1 = 6; phase2 = 7;
    case 14
        phase1 = 7; phase2 = 8;
    case 15
        phase1 = 8; phase2 = 9;
    case 16
        phase1 = 9; phase2 = 10;
    case 17
        phase1 = 1; phase2 = 4;
    case 18
        phase1 = 2; phase2 = 5;
    case 19
        phase1 = 3; phase2 = 6;
    case 20
        phase1 = 4; phase2 = 7;
    case 21
        phase1 = 5; phase2 = 8;
    case 22
        phase1 = 6; phase2 = 9;
    case 23
        phase1 = 1; phase2 = 3;
    case 24
        phase1 = 4; phase2 = 6;
    case 25
        phase1 = 5; phase2 = 7;
    case 26
        phase1 = 6; phase2 = 8;
    case 27
        phase1 = 7; phase2 = 9;
    case 28
        phase1 = 8; phase2 = 10;
    case 29
        phase1 = 1; phase2 = 6;
    case 30
        phase1 = 2; phase2 = 7;
    case 31
        phase1 = 3; phase2 = 8;
    case 32
        phase1 = 4; phase2 = 9;
    case 33
        phase1 = 5; phase2 = 10;
    case 34
        phase1 = 4; phase2 = 10;
    case 35
        phase1 = 1; phase2 = 7;
    case 36
        phase1 = 2; phase2 = 8;
    case 37
        phase1 = 4; phase2 = 10;
end  

% Generate one period of Gold code
for i=1:1023
    G1newBit=xor(G1(3),G1(10));
    G2newBit=xor(G2(2),G2(3));
    G2newBit=xor(G2newBit,G2(6));
    G2newBit=xor(G2newBit,G2(8));
    G2newBit=xor(G2newBit,G2(9));
    G2newBit=xor(G2newBit,G2(10));
    
    G2i=xor(phase1,phase2); % G2 output
    
    code(i)=xor(G2i,G1(10));% CA Code at index i
    
    G1=[G1newBit G1(1:9)];
    G2=[G2newBit G2(1:9)];
end
