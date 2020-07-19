% Illianna Izabal
% Notes: E(6), A(5), D(4), G(3), B(2), E(1)
% G(3), B(2), E(1) High Pitch; High Frequency, Small Wavelength
% E(6), A(5), D(4) Low Pitch; Low Frequency, Big Wavelength
%Reference=https://en.wikipedia.org/wiki/Guitar_tunings
% 6 Acoustic Guitar Strings in Hz;
% E = 0:1:82; 
% A = 82:1:110; 
% D = 110:1:146; 
% G = 146:1:196; 
% B = 196:1:247; 
% Ehigh = 247:1:330; 

syms x
y = sin(Hz*x);

if Hz > 0 && Hz < 82            %fun fact: humans cannot hear below 20Hz.
   d = 'E(Low Pitch)';
elseif Hz >= 82 && Hz < 110
    d = 'A';
elseif Hz >= 110 && Hz < 146
    d = 'D';
elseif Hz >= 146 && Hz < 196
    d = 'G';
elseif Hz >= 196 && Hz < 247
    d = 'B';
elseif Hz >= 247 && Hz < 330    %part 2: humans cannot hear above 20,000Hz.
    d = 'E(High Pitch)';
end
