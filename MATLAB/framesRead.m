% Convert Polarius digitizer frames file to gcode coordinates format. 

% [out] = function readFrame(file);
outfile = 'skull_cut.txt'; %output file
file = 'frames.frm';


M = dlmread(file);
axis = M(:,1:3);
angle = M(:,4);
trans = M(:,5:7);
x = trans(:,1);
y = trans(:,2);
z = trans(:,3);

%numbers can be adjusted to fit the machine space. (x,y) may have been swapped.
xa = x - 45;
ya = y + 45;
za = z/10; %add a value if need to do more loop.
a = [xa ya];


vel = [350]; % Specify laser velocity here
out1 = a(1,:)'; % First line of the file
outrest = a(2:size(a,1),:)'; % Rest of the file
home = zeros([3 1]); % home position [0 0 0]

%Write the file
fileID = fopen(outfile,'w');
fprintf(fileID,'G21\r\n'); % Specify unit: mm
fprintf(fileID,'G64\r\n'); % Activate path control mode
fprintf(fileID,'G90\r\n'); % Activate absolute (world) distance mode
fprintf(fileID,'s3400\r\n'); % Set spindle (laser) parameter
fprintf(fileID,'G1 '); % Jog the machine linearly
firstline = 'X %4.6f Y %4.6f';
fprintf(fileID,firstline,out1);
fprintf(fileID,'M3\r\n'); %Start spindle (laser)
formatSpec = 'X %4.6f Y %4.6f \r\n';
fprintf(fileID,formatSpec,outrest);
fprintf(fileID,'M5\r\n'); % End spindle (laser)
fprintf(fileID,formatSpec,home);
fprintf(fileID,'M2\r\n'); % End system program

fclose(fileID);
