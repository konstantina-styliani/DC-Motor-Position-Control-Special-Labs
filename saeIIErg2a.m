

% Set the desired position
des_pos = 2;

%   The input setpoint is in Volts and can vary from 0 to 10 Volts because the position pot is refered to GND

V_7805=5.48;
Vref_arduino=5;

legacy = false;

if ~exist('a','var')
    % clear
    % delete(instrfind({'Port'},{'COM7'}));    
    if legacy
        a=arduino('COM3'); % 'COM3' needs to be set manually into the correct port of Arduino
    else
        a = arduino;
    end
end

% OUTPUT ZERO CONTROL SIGNAL TO STOP MOTOR  %
if legacy
    analogWrite(a,6,0);
    analogWrite(a,9,0);
else
    writePWMVoltage(a, 'D6', 0)
    writePWMVoltage(a, 'D9', 0)
end

 k1 = 1.75
 k2 = 0.122
 kr = k1

 ref = 5


positionData = [];
positionDataI = [];
velocityData = [];
uData = [];
timeData = [];
zData = [];

t=0;

% CLOSE ALL PREVIOUS FIGURES FROM SCREEN

close all

% WAIT A KEY TO PROCEED
disp(['Connect cable from Arduino to Input Power Amplifier and then press enter to start controller']);
pause()



%START CLOCK
tic
 
 
while(t<5)  
    
if legacy
    velocity = analogRead(a,3);
    position = analogRead(a,5);
    theta = 3 * Vref_arduino * position / 1023;
    vtacho = 2 * (2 * velocity * Vref_arduino / 1023 - V_7805);
    
else
    position = readVoltage(a, 'A5'); % position
    velocity = readVoltage(a,'A3'); % velocity
    theta = 3 * Vref_arduino * position / 5;
    vtacho = 2 * (2 * velocity * Vref_arduino / 5 - V_7805);
   
end
    ref=5;

 u = - k1 * theta - k2 * vtacho + kr * ref; 

 %   z_dot =theta - ref;  %z_dot=y-r

  
 %   if t==0
%        z = z_dot*toc;
 %   else
  %      z = zData(end) + z_dot*( toc - timeData(end) ); %ολοκλήρωμα
   % end
 

 %My Controllers
% u = -k1*theta -k2*vtacho -kz*z;

if u > 0
    if legacy
        analogWrite(a,6,0);
        analogWrite(a,9, min(round(e/2 * 255/ Vref_arduino) , 255)); %min is used to saturate
    else        
        writePWMVoltage(a, 'D6', 0);
        writePWMVoltage(a, 'D9', min(abs(u) / 2, 5));
    end
else
     if legacy
        analogWrite(a,9,0);
        analogWrite(a,6, min(round(-e/2 * 255/ Vref_arduino) , 255)); %min is used to saturate
    else        
        writePWMVoltage(a, 'D9', 0);
        writePWMVoltage(a, 'D6', min(abs(u) / 2, 5));

     end
end


t=toc;

    
timeData = [timeData t];
positionData = [positionData theta];
velocityData = [velocityData vtacho];
uData = [uData u];
positionDataI=[positionDataI ref];
zData = [zData z];

end

% OUTPUT ZERO CONTROL SIGNAL TO STOP MOTOR  %
if legacy
    analogWrite(a,6,0);
    analogWrite(a,9,0);
else
    writePWMVoltage(a, 'D6', 0)
    writePWMVoltage(a, 'D9', 0)
end


disp(['End of control Loop. Press enter to see diagramms']);
pause();


figure
plot(timeData,positionData);  %theta
title('position')

figure
plot(timeData,velocityData);  %vatcho
title('velocity')

%figure
%plot(timeData, zData);
%title('z') % % %

figure
plot(timeData,uData);
title('controller')

figure
plot(timeData,positionData); %theta τρέχουσα θέση
hold on 
plot(timeData,positionDataI); %ref επιθυμητή θέση
title('position-reference')
legend('pos', 'ref')
disp('Disonnect cable from Arduino to Input Power Amplifier and then press enter to stop controller');
pause();

