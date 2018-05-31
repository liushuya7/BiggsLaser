% ** Only good for varying scan speed **

%function output = gen_gcode(char,num,length,gap_dist,start_pos)
function gcode_speed()
% Generate G_code to cut multiple lines at either varying scan spped or
% varying laser power
% Input: char - mode selection: 'F' - varying scan speed 
%                               'S' - varying laser power
%        num - number of cuts
%        row/col - dimension of block area
%        length - length of each cut
%        gap_hori - distance between horizontal block
%        gap_vert - distance between vertical block
%        start_pos - starting position coordinate (for G54)
%        height - focal plane (Z)
%
% Output: Gcode - X Y Z F S
% For example:
%   char = 'F'; 
%   num = 5; 
%   length = 50; % mm (d in the figure)
%   gap_dist = 25; % mm (z in the figure)
%   start_pos = [0 0];

%% Input parameters here
char = 'F'; % F - varying scan speed, S - varying laser power
num = 5; % number of blocks for cutting
row = 4; % number of row
col = 2; % number of column

length = 25.5; % mm (length of a single cut pass)
gap_vert = 20; % mm (gap between adjacent blocks in a column)
gap_hori = 40; % mm (gap between adjacent blocks in a row)
pos = [0 0]; % [x y]
height = 0; % focal plane height w/t G54 work coordinates
fastF = 5000; % holder for G0

row_last = mod(num,row);
%% varying scan speed
%if char == 'F' || 'f'
if strcmp(char,'F') || strcmp(char,'f')
    prompt = 'What is the laser power? ';
    power = input(prompt);
    prompt2 = 'What is the starting scan speed? ';
    start = input(prompt2);
    prompt3 = 'What is the increment? ';
    inc = input(prompt3);
    
    x = start; %for gcode format use
    mat = [];
    matf = [];

%     for i = 1:num
%         mat_temp1 = [pos(1) pos(2)+(gap*(i-1)) start+(inc*(i-1)) 0];
%         mat_temp2 = [pos(1)+length pos(2)+(gap*(i-1)) start+(inc*(i-1)) power];
%         mat_temp = [mat_temp1;mat_temp2];
%         mat = [mat;mat_temp];
%     end

    if row_last == 0
        
        for i = 1:(num/row)
            for j = 1:row
                mat_temp1 = [pos(1)+(gap_hori*(i-1))        pos(2)+(gap_vert*(j-1)) fastF 0];
                mat_temp2 = [pos(1)+(gap_hori*(i-1))+length pos(2)+(gap_vert*(j-1)) start+(inc*((i-1)*row+j-1)) power];
                mat_temp = [mat_temp1;mat_temp2];
                mat = [mat;mat_temp];
            end
        end
    else
        
        for i = 1:col-1
            for j = 1:row
                mat_temp1 = [pos(1)+(gap_hori*(i-1))        pos(2)+(gap_vert*(j-1)) fastF 0];
                mat_temp2 = [pos(1)+(gap_hori*(i-1))+length pos(2)+(gap_vert*(j-1)) start+(inc*((i-1)*row+j-1)) power];
                mat_temp = [mat_temp1;mat_temp2];
                mat = [mat;mat_temp];
            end
        end

        for q = 1:row_last
            mat_temp11 = [pos(1)+(gap_hori*(col-1))        pos(2)+(gap_vert*(q-1)) fastF 0];
            mat_temp22 = [pos(1)+(gap_hori*(col-1))+length pos(2)+(gap_vert*(q-1)) start+(inc*((i)*row+q-1)) power];
            mat_tempp = [mat_temp11;mat_temp22];
            matf = [matf;mat_tempp];
        end

        mat = [mat;matf];
    end


%% varying laser power
else
    prompt = 'What is the scan speed? ';
    speed = input(prompt);
    prompt2 = 'What is the starting laser power? ';
    start = input(prompt2);
    prompt3 = 'What is the increment? ';
    inc = input(prompt3);
    
    x = speed; %for gcode format use
    mat = [];
    matf = [];
%     for i = 1:num
%         mat_temp1 = [pos(1) pos(2)+(gap*(i-1)) speed 0];
%         mat_temp2 = [pos(1)+length pos(2)+(gap*(i-1)) speed start+(inc*(i-1))];
%         mat_temp = [mat_temp1;mat_temp2];
%         mat = [mat;mat_temp];
%     end

    if row_last == 0
        
        for i = 1:(num/row)
            for j = 1:row
                mat_temp1 = [pos(1)+(gap_hori*(i-1))        pos(2)+(gap_vert*(j-1)) fastF 0];
                mat_temp2 = [pos(1)+(gap_hori*(i-1))+length pos(2)+(gap_vert*(j-1)) speed start+(inc*((i-1)*row+j))];
                mat_temp = [mat_temp1;mat_temp2];
                mat = [mat;mat_temp];
            end
        end
    else
        
        for i = 1:col-1
            for j = 1:row
                mat_temp1 = [pos(1)+(gap_hori*(i-1))        pos(2)+(gap_vert*(j-1)) fastF 0];
                mat_temp2 = [pos(1)+(gap_hori*(i-1))+length pos(2)+(gap_vert*(j-1)) speed start+(inc*((i-1)*row+j))];
                mat_temp = [mat_temp1;mat_temp2];
                mat = [mat;mat_temp];
            end
        end

        for q = 1:row_last
            mat_temp11 = [pos(1)+(gap_hori*(col-1))        pos(2)+(gap_vert*(q-1)) fastF 0];
            mat_temp22 = [pos(1)+(gap_hori*(col-1))+length pos(2)+(gap_vert*(q-1)) speed start+(inc*((i-1)*row+j))];
            mat_tempp = [mat_temp11;mat_temp22];
            matf = [matf;mat_tempp];
        end

        mat = [mat;matf];
    end

end

%% convert to G-code format
outfile = 'Gcode_speed.gcode'; % Specify output file here
home = zeros([4 1]); % home position [0 0 0 0]
home(3) = x;
first = [pos(1) pos(2) height fastF 0];
%Write the file
fileID = fopen(outfile,'w');
fprintf(fileID,'G21\n'); % Specify unit: mm 
%fprintf(fileID,'G64\n'); % Activate path control mode
fprintf(fileID,'G90\n'); % Activate absolute (world) distance mode
fprintf(fileID,'M4\n'); % Start laser
%fprintf(fileID,'s3400\n'); %Activate spindle (laser)
fprintf(fileID,'G1 '); % 

formatSpec_first = 'X %4.1f Y %4.1f Z %4.1f F %4.1f S %4.1f\n';
fprintf(fileID,formatSpec_first,first);

formatSpec = 'X %4.1f Y %4.1f F %4.1f S %4.1f\n';
fprintf(fileID,formatSpec,mat');
% fprintf(fileID,'M5\n'); % End spindle (laser)
% fprintf(fileID,formatSpec,outlast);
%fprintf(fileID,formatSpec,home);
fprintf(fileID,'M2\n'); % End system program

fclose(fileID);
