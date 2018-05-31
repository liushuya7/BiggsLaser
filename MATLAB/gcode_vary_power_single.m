
function gcode_power_single()
% Generate G_code to cut one line at varying laser power
% Input: length - length of each cut
%        start_pos - starting position coordinate (for G54)
%
% Output: Gcode - X Y Z F S

%% adjust parameters here
char = 'D'; % cut method. D: Discrete. C: continuous.
pos = [0 0]; % [x y]
length = 55; % cut length (L) [mm]
height = 0; % focal plane height w/t G54 work coordinates (z)
speed = 400; % cut speed (F)
res = 20; % resolution (R)

s_min = 100; % min laser power
s_max = 1000; % max laser power

gap = 0.5; % gap distance between each cut 
%%
len_step = length/res; % cut distance for each power increment
s_step = (s_max-s_min)/res;

mat_init = [pos(1) pos(2) height speed 0]; % set to initial config [X Y Z F S]
matC = [];
mat_tempp = [];
matD = [];

% continuous cut
for i = 1:res+1
    mat_temp = [pos(1)+(len_step*i) s_min+(s_step*(i-1))]; %[X S]
    matC = [matC;mat_temp];
end

% discrete cut (turn laser on/off)
for i = 1:res+1
    mat_temp_1 = [pos(1)+(len_step*i)-gap s_min+(s_step*(i-1))]; %[X S]
    mat_temp_2 = [pos(1)+(len_step*i)     0];
    mat_tempp = [mat_temp_1;mat_temp_2];
    matD = [matD;mat_tempp];
end

if strcmp(char,'C') || strcmp(char,'c')
    mat_final = matC;
else
    mat_final = matD;
end


%% convert to G-code format
outfile = 'Gcode_power_single.gcode'; % Specify output file here
home = mat_init; % set to initial position
last = [pos(1) 0];
%Write the file
fileID = fopen(outfile,'w');
fprintf(fileID,'G21\n'); % Specify unit: mm 
%fprintf(fileID,'G64\n'); % Activate path control mode
fprintf(fileID,'G90\n'); % Activate absolute (world) distance mode
fprintf(fileID,'M4\n'); % Start laser
%fprintf(fileID,'s3400\n'); %Activate spindle (laser)
fprintf(fileID,'G1 '); % 

% set initial config
formatSpec_start = 'X %4.1f Y %4.1f Z %4.1f F %4.1f S %4.1f\n';
fprintf(fileID,formatSpec_start,home);

% set the experiment run
formatSpec = 'X %4.1f S %4.1f\n';
fprintf(fileID,formatSpec,mat_final');

%fprintf(fileID,'M5\n'); % End spindle (laser)

% final position (back to starting position)
fprintf(fileID,formatSpec,last);
fprintf(fileID,'M2\n'); % End system program

fclose(fileID);


end

