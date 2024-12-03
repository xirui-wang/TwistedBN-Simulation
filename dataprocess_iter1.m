%% calculate Vp1 from E1
L  = 40e-9;
%
mfiledir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))); %% parent folder
filename = fullfile(mfiledir,'\matlab_code_assumption_n_result','Enrealation.mat');
A=load(filename);
n=A.n;
Eaxis=A.Eaxis;
% ni=5*10^12; % the carrier density
% Ex=interp1(n,Eaxis,ni) % the chemical potential

mfiledir = fileparts(fileparts(fileparts(mfilename('fullpath')))); %% parent folder
fid = fopen(fullfile(mfiledir,'\comsol_files','E1_iter0.txt'),'rt');
C = textscan(fid, '%f%f%f', 'MultipleDelimsAsOne',true, 'Delimiter',' ', 'HeaderLines',8);
fclose(fid);
A = cell2mat(C);

V0 = 1;

x = A(:,1);
y = A(:,2);
z = A(:,3);

N = round(sqrt(size(x,1)));
[xq,yq] = meshgrid(linspace(-L,L,N), linspace(-L,L,N));
zq = griddata(x,y,z,xq,yq);

figure(1)
% pointsize = 10;
% scatter(x, y, pointsize, z);
pcolor(xq, yq,zq);
shading flat
title('electric field')
colorbar

figure(2)
% Vq = -0.0288*zq*16.6;
Vq=-interp1(n,Eaxis,zq*16.6*1e12); %% chemical potential
pcolor(xq, yq, Vq);
title('quantum voltage')
shading flat
colorbar
colormap("default")

%% import V1 V2
fid = fopen(fullfile(mfiledir,'\comsol_files','V1_iter0.txt'),'rt');
C = textscan(fid, '%f%f%f', 'MultipleDelimsAsOne',true, 'Delimiter',' ', 'HeaderLines',8);
fclose(fid);
A = cell2mat(C);

x = A(:,1);
y = A(:,2);
z = A(:,3);

V1 = griddata(x,y,z,xq,yq);

figure(5)
% pointsize = 10;
% scatter(x, y, pointsize, z);
pcolor(xq, yq,V1);
shading flat
title('voltage1')
colorbar

%% calculate V1, Vq1 
Vq1_new = (Vq+V1)/2;

figure(7)
% Vq = -0.47*sqrt(abs(zq)).*sign(zq);
pcolor(xq, yq, Vq1_new);
title('quantum voltage 1 new')
shading flat
colorbar
colormap("default")

%% export Vq1new, Vq2new
deltaV = max(max(Vq1_new(N*0.25:N*0.75,N*0.25:N*0.75)));
deltaV2 = min(min(Vq1_new(N*0.25:N*0.75,N*0.25:N*0.75)));
fileID = fopen(fullfile(mfiledir,'\data\quantum_potential_to_comsol\peak_value','deltaV_iter1.txt'),'w');
fprintf(fileID,'%% %12s %12s\n','V1new' ,'V1new2');
fprintf(fileID,'%12.18f\t%12.18f\n',deltaV,deltaV2);
fclose(fileID);

toremove = isnan(Vq1_new);
xq1=xq;
yq1=yq;
xq1(toremove) = [];
yq1(toremove) = [];
Vq1_new(toremove) = [];
% Vnew = ones(size(Vnew,1),1);
A2 = [reshape(xq1,1,[]);reshape(yq1,1,[]);reshape(Vq1_new,1,[])]';

fileID = fopen(fullfile(mfiledir,'\comsol_files','Vq1_new_iter1.txt'),'w');
fprintf(fileID,'%% %6s %6s %12s\n','x','y','V1new');
fprintf(fileID,'%10.18f\t%10.18f\t%12.18f\n',A2');
fclose(fileID);
