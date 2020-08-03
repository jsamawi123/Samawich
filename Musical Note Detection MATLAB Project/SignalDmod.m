% Cesar Martinez Melgoza
% input: y(Signal), Fc(Carrier), Fs(Sample), freqdev;(Fs >= 2Fc)
TOL = 10^-2;
z = fmdemod(D,Hz,4*Hz,1); % Experiment. 1 deviaton or 2?

z1 = z; %z1 used to print on subplot, z will be used again below...

% Call fourier 
v = length(z); 
z(1,:) = abs(z);
for i = 1:1:v
    for j = i+1:1:v
        if z(i) < z(j)
            temp = z(i);
            %The smaller element is swapped with the bigger one
            z(i)=z(j);
            % The smaller element is set to ahead of the bigger onefro
            z(j) = temp;
        end
    end

end