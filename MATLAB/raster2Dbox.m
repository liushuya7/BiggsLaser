function p = path2DBox(b)
% Generate a engranving path for laser pocket milling from a 2D box

% Parameters:
% laser focal diameter
d = 0.5;
% choose principle scanning axis: X or Y
scan_dirct = 'X';
% defult feedforward speed mm/min
F_default = 1000;
% auxiliary axis step size / layout resolution
aux_step = d/2;

% Load in the box dimension
x_min = b(1);
y_min = b(2);
x_max = b(3);
y_max = b(4);

% Compute inner offset box by focal diameter
offset = d/2;
x_min_offset = x_min + offset;
y_min_offset = y_min + offset;
x_max_offset = x_max - offset;
y_max_offset = y_max - offset;

% Linear array bi-directionally by aux_step from the middle line to offset bondaries
array_lines = 1;
bottom_point = zeros(1,2);
% auxiliary axis inward extra boundary ratio
extra_bond = 0.5;
if scan_dirct == 'X'
    bottom_point(1) = x_min_offset;
    % Compute the middle line first
    y_cur = (y_max_offset + y_min_offset)/2;
    while y_cur > (y_min_offset + extra_bond*offset)
        % add 2 new lines if didn't reach the boundary
        array_lines = array_lines + 2;
        % move the cursor 1 step down
        y_cur = y_cur - aux_step;
        bottom_point(2) = y_cur;
    end
else
    bottom_point(2) = y_min_offset;
    % Compute the middle line first
    x_cur = (x_max_offset + x_min_offset)/2;
    while x_cur > (x_min_offset +  + extra_bond*offset)
        % add 2 new lines if didn't reach the boundary
        array_lines = array_lines + 2;
        % move the cursor 1 step down
        x_cur = x_cur - aux_step;
        bottom_point(1) = x_cur;
    end
end

% Generate the path
path = zeros(array_lines,2);
if scan_dirct == 'X'
    x_range = x_max_offset - x_min_offset;
    % create a point cursor
    point = bottom_point;
    % a flip sign for looping thru all the points
    k = 1;
    % each line edge consists of 2 points
    for i = 1:2*array_lines
        path(i,:) = point;
        % if even number, go UP; else, go RIGHT or LEFT
        if rem(i,2) == 0
            point(2) = point(2) + aux_step;
        else
            point(1) = point(1) + k * x_range;
            % flip the sign for next loop
            k = -1*k;
        end
    end
else
    y_range = y_max_offset - y_min_offset;
    % create a point cursor
    point = bottom_point;
    % a flip sign for looping thru all the points
    k = 1;
    % each line edge consists of 2 points
    for i = 1:2*array_lines
        path(i,:) = point;
        % if even number, go RIGHT; else, go UP or DOWN
        if rem(i,2) == 0
            point(1) = point(1) + aux_step;
        else
            point(2) = point(2) + k * y_range;
            % flip the sign for next loop
            k = -1*k;
        end
    end
end

% plot the path
plot(path(:,1),path(:,2),'-')
axis([x_min x_max y_min y_max])
p = path;

