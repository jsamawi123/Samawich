% Yocelin Esqueda-Briones
%%interleaving file

t = 0:10;
max = Hz;
min = Hz/2;
r = min + (max-min)*rand(1,length(t));
D = cos(5*r+4) + sin(Hz); % Plotted signal
