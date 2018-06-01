%CREATEFRAMES - Create the frames
pts = load('Defect_Points.xyz')';
mesh = f_stlMesh_to_surface(f_read_stl('Skull-WithDefect_200kFaces_Implant.stl'));

nodes = mesh.nodeData';

implantPlane = [11.93598 -26.82317 57.70747
    42.69872 -8.70252 3.39085
    75.68873 -64.70840 3.39085
    44.92599 -82.82905 57.70747];
N  = f_fit_plane(implantPlane');

z = -N(1:3)';
x = [1;0;0];
y = cross(z, x);
y = y/norm(y);
x = cross(y,z);
x = x/norm(x);

R = [x y z];

T = zeros(4,4,length(pts));
T(1:3,4,:) = pts;
T(1:3,1:3,:) = repmat(R, 1, 1, length(pts));
T(4,4,:) = 1;
%%
fid = fopen('framesBigDiff.frm','w');
for i=1:25:length(T)
    [ax, ang] = f_R_to_angle_axis(T(1:3,1:3,i));
    ang = ang * pi/180;
    fprintf(fid, '%f ', [ax(:); ang; T(1:3,4,i)]);
    fprintf(fid, '\n');
end
fclose(fid);
    
%%
figure;
hPts = f_plot3(pts,'r.');
hold on;
hMesh = f_show_surface(mesh);
camlight left
lighting gouraud
set(hMesh,'facealpha',0.4);
axis equal
t = Triad(gca, T(:,:,100), 5);