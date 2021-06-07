% – Modeling and Simulation of Signals and Systems: Note Detection Project
% By: James Samawi 5/7/20
% REQUIRED FILES: main.m, interleaving.m, Chromatic.m, SignalDmod.m
% Required Toolboxes: Communications and Signal Processing

prompt = '\nWelcome to our project! \nPress Enter to continue, "2" to exit, or "3" to learn more about this project. \n';
getkey = input(prompt,'s'); %getkey is a matlab function that takes input in form of keycode

switch getkey
    case getkey ~= 13 % Enter keycode is 13
        while 1
        Hz = input('Enter Non-Zero frequency(Hz): ');
            if Hz <= 0
            fprintf('Hz must be a positive, non-zero integer.\n');
            else
                break; % exits while, and program continues
            end
        end
    case '2'
        return; % quits program
    case '3'
        fprintf('\nThis program is inspired by a chromatic tuner, which measures the frequency played by a certain \ninstrument (or sometimes any instrument) and outputs the equivalent musical note to which the \nmusician then physically tunes the instrument to match the frequency closer to the output note. \n \n');
        fprintf('After entering a frequency, it will be a part of a chosen carrier wave function which will be \nrandomized to simulate someone playing a tune on their acoustic guitar. The wave will then enter \na fourier transform demodulation function which will filter a portion of the randomized \nwave, and will sort FM frequencies by maximum to minimum. At the same time, the frequency \nthat was entered will be matched with the appropriate musical note frequency of an acoustic guitar. \nBelow are the open string note equivalent frequencies in Hz for an acoustic guitar: \n \n \t');
        fprintf('E (low) = 0:1:82 \n\t'); 
        fprintf('A = 82:1:110 \n\t'); 
        fprintf('D = 110:1:146 \n\t'); 
        fprintf('G = 146:1:196 \n\t'); 
        fprintf('B = 196:1:247 \n\t'); 
        fprintf('E (high) = 247:1:330 \n\n'); 
        
        while 1
        Hz = input('Enter Non-Zero frequency(Hz): ');
            if Hz <= 0
            fprintf('Hz must be a positive, non-zero integer.\n');
            else
                break; % exits while, and program continues
            end
        end
        
    otherwise
        disp('Try again')
        while 1
        Hz = input('Enter Non-Zero frequency(Hz): ');
            if Hz <= 0
            fprintf('Hz must be a positive, non-zero integer.\n');
            else
                break; % exits while, and program continues
            end
        end
end

% PLOTS:

%figure(1);
interleaving;
subplot(221);
plot(t,D);
title('Random Signal Generated');
xlabel('time');
ylabel('Amplitude');
grid on;

%figure(2);
SignalDmod;
subplot(222);
plot(t,z1);
title('Signal Demodulated');
xlabel('time');
ylabel('Amplitude');
grid on;

%figure(3); 
subplot(223);
plot(t,z);
title('Sorted FM Signal');
xlabel('time');
ylabel('Frequency (MAX -> MIN)');
grid on;

%figure(4); 
Chromatic;
subplot(224);
fplot(y, [0 0.5]);
title(d);
xlabel('x');
ylabel('y(x)');
grid on;