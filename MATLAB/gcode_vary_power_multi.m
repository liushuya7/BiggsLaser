
function gcode_vary_power()
% Generate G_code to cut one line at varying laser power
% Input: num - number of cuts
%        row/col - dimension of block area
%        length - length of each cut
%        gap_hori - distance between horizontal block
%        gap_vert - distance between vertical block
%        start_pos - starting position coordinate (for G54)
%        height - focal plane (Z)

% Output: Gcode - X Y Z F S

%% adjust parameters here
char = 'C'; % cut method. D: Discrete. C: continuous.

% Set the dimension
num = 10; % number of blocks for cutting
row = 5; % number of row
col = 3; % number of column

% set distance of each block and distancce in between
length = 50; % cut length (L) of each block [mm]
gap_vert = 25; % gap between adjacent blocks in a column
gap_hori = 80; % gap between adjacent blocks in a row

pos = [0 0]; % set starting position [x y]
height = 0; % focal plane height w/t G54 work coordinates (z)
speed = 400; % cut speed (F)
res = 10; % resolution (R)

s_min = 100; % min laser power
s_max = 1000; % max laser power
fastF = 5000; % holder for G0

gap = 1; % gap distance between each cut 

%%
row_last = mod(num,row);
len_step = length/res; % cut distance for each power increment per block
s_step = (s_max-s_min)/res/num; % varying range of laser power per block
s_block = (s_max-s_min)/num; % incremental initial laser power at each block

mat_init = [pos(1) pos(2) height fastF 0]; % set to initial config [X Y Z F S]
mat = [];
matf = [];

% get the starting position for each block
if row_last == 0
    
    for i = 1:(num/row)
        for j = 1:row
            %[X Y F S]
            mat_temp = [pos(1)+(gap_hori*(i-1)) ...
                        pos(2)+(gap_vert*(j-1)) ...
                        fastF ...
                        0];
            mat = [mat;mat_temp];
        end
    end
    
else
    for i = 1:col-1
        for j = 1:row
            mat_temp1 = [pos(1)+(gap_hori*(i-1)) ...
                         pos(2)+(gap_vert*(j-1)) ...
                         fastF ...
                         0];
            mat = [mat;mat_temp];
        end
        
        for q = 1:row_last
            mat_temp11 = [pos(1)+(gap_hori*(col-1)) ...
                          pos(2)+(gap_vert*(q-1)) ...
                          fastF ...
                          0];
            matf = [matf;mat_tempp11];
        end
        mat = [mat;matf];
   end
end

%% cut with a range of laser power at each block
matC = [];
matD = [];
for ii = 1:size(mat,1)
    x_ini = mat(ii,1);
    y_ini = mat(ii,2);
    mat_temp2f_C = [];
    mat_temp2f_D = [];
    for jj = 1:res
        % [X Y F S]
        % contiuous cut
        mat_temp2_C = [x_ini+(len_step*jj)...
                     y_ini ...
                     speed ...
                     s_min+(s_block*(ii-1))+(s_step*(jj-1))]; 
                 
        mat_temp2f_C = [mat_temp2f_C;mat_temp2_C];    
        
        %discrete cut
        mat_temp2_D1 = [x_ini+(len_step*jj)-gap...
                       y_ini ...
                       speed ...
                       s_min+(s_block*(ii-1))+(s_step*(jj-1))]; 
                   
        mat_temp2_D2 = [x_ini+(len_step*jj)...
                        y_ini ...
                        speed ...
                        0]; 
        mat_temp2_D = [mat_temp2_D1;mat_temp2_D2];
        mat_temp2f_D = [mat_temp2f_D;mat_temp2_D];
         
    end
    
    matw_C = [mat(ii,:);mat_temp2f_C];
    matC = [matC;matw_C];
    
    matw_D = [mat(ii,:);mat_temp2f_D];
    matD = [matD;matw_D];
    
end

if strcmp(char,'C') || strcmp(char,'c')
    mat_final = matC;
else
    mat_final = matD;
end

%% convert to G-code format
outfile = 'Gcode_power_multi.txt'; % Specify output file here
home = mat_init; % set to initial position
last = [pos(1) pos(2) fastF 0];
%Write the file
fileID = fopen(outfile,'w');
fprintf(fileID,'G21\n'); % Specify unit: mm
fprintf(fileID,'G64\n'); % Activate path control mode
fprintf(fileID,'G90\n'); % Activate absolute (world) distance mode
fprintf(fileID,'M3\n'); % Start laser
%fprintf(fileID,'s3400\n'); %Activate spindle (laser)
fprintf(fileID,'G1 '); %

% set initial config
formatSpec_start = 'X %4.1f Y %4.1f Z %4.1f F %4.1f S %4.1f\n';
fprintf(fileID,formatSpec_start,home);

% set the experiment run
formatSpec = 'X %4.1f Y %4.1f F %4.1f S %4.1f\n';
fprintf(fileID,formatSpec,mat_final');

%fprintf(fileID,'M5\n'); % End spindle (laser)

% final position (back to starting position)
fprintf(fileID,formatSpec,last);
fprintf(fileID,'M2\n'); % End system program

fclose(fileID);


end

