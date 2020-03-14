close all; clear all; clc % Clean all variables.

Undata=load('/Users/yuhongliu/Downloads/Testdata.mat');
Undata=Undata.Undata;

L=15; % spatial domain
n=64; % Fourier modes
x2=linspace(-L,L,n+1); x=x2(1:n); y=x; z=x;
k=(2*pi/(2*L))*[0:(n/2-1) -n/2:-1]; ks=fftshift(k);
[X,Y,Z]=meshgrid(x,y,z); % Create spatial domain.
[Kx,Ky,Kz]=meshgrid(ks,ks,ks); % Create spectral domain.

%%

% In spatial domain.
for j=1:20
Un(:,:,:)=reshape(Undata(j,:),n,n,n);
close all, isosurface(X,Y,Z,abs(Un),0.4) 
axis([-20 20 -20 20 -20 20]), grid on, drawnow, pause(1)
xlabel('x'), ylabel('y'), zlabel('z')
title('Visualisation for spatial domain data')
end

%%

% In frequency domain.
for j = 1:20
    Un(:,:,:) = reshape(Undata(j,:),n,n,n);
    Unt = fftn(Un);
    Untshift = fftshift(Unt)/max(max(max(abs(Unt))));
    close all, isosurface(Kx,Ky,Kz,abs(Untshift),0.4) 
    axis([-8 8 -8 8 -8 8]), grid on, drawnow, pause(1)
    xlabel('kx'), ylabel('ky'), zlabel('kz')
    title('Visualisation for frequency domain data')
end


%%

% Averaging the signals.
Unave=zeros(n,n,n);
Untave=zeros(n,n,n);
for i = 1:20
    Un(:,:,:) = reshape(Undata(i,:),n,n,n);
    Unave=Unave+Un;
    Unt = fftn(Un);
    Untave=Untave+Unt;
end
Unave=Unave/10.0; % 20.; % The value was too small for the graph.
Untave=fftshift(Untave)/20.;

figure(1)
isosurface(X,Y,Z,abs(Unave),0.4)
axis([-20 20 -20 20 -20 20]), grid on, drawnow
xlabel('x'), ylabel('y'), zlabel('z')
title('Visualisation for averaged spatial domain data')

figure(2)
isosurface(Kx,Ky,Kz,abs(Untave)/max(max(max(abs(Untave)))),0.4)
axis([-8 8 -8 8 -8 8]), grid on, drawnow
xlabel('kx'), ylabel('ky'), zlabel('kz')
title('Visualisation for averaged frequency domain data')

abs_Untave = abs(Untave)/max(max(max(abs(Untave))));
[omega_x_ind, omega_y_ind, omega_z_ind] = ind2sub(size(abs_Untave), find(abs_Untave == max(abs_Untave(:))));
omega_x = ks(omega_y_ind);
omega_y = ks(omega_x_ind);
omega_z = ks(omega_z_ind);

% The data still seems pretty noisy.
% But according to the frequency domain, we should filter around omega_x,
% omega_y, omega_z = 1.89, -1.05, 0.0.

%%

% We try to filter it using Gaussian filter.

filter=exp(-.2*((fftshift(Kx)-omega_x).^2+(fftshift(Ky)-omega_y).^2+(fftshift(Kz)-omega_z).^2));

marble_pos=zeros(20, 3);
for i=1:20
    Un(:,:,:) = reshape(Undata(i,:),n,n,n);
    Unt = fftn(Un);
    Unft = filter.*Unt;
    Unf=ifftn(Unft);
    
    % close all, isosurface(X,Y,Z,abs(Unf),0.4) 
    % axis([-20 20 -20 20 -20 20]), grid on, drawnow, pause(1)
    isosurface(X,Y,Z,abs(Unf),0.4),
    xlabel('x'), ylabel('y'), zlabel('z')
    title('Marble path in spatial domain')
    axis([-20 20 -20 20 -20 20]), grid on, drawnow
    
    %close all, isosurface(Kx,Ky,Kz,abs(fftshift(Unft))/max(max(max(abs(fftshift(Unft))))),0.4) 
    % xlabel('kx'), ylabel('ky'), zlabel('kz')
    % title('Marble frequency')
    %axis([-8 8 -8 8 -8 8]), grid on, drawnow, pause(1)
    
    % Now we try to extract the path.
    % We use the peak value's location as the marble's location.
    abs_Unf = abs(Unf);
    [pos_x, pos_y, pos_z] = ind2sub(size(abs_Unf), find(abs_Unf == max(abs_Unf(:))));
    marble_pos(i,:)=[x(pos_y) x(pos_x) x(pos_z)];
end

% We found the marble!

%%

% Plot the path by itself.
figure(3)
plot3(marble_pos(:,1), marble_pos(:,2), marble_pos(:,3), 'r-', 'Linewidth',[5])
xlabel('x'), ylabel('y'), zlabel('z')
title('Marble path in spatial domain')
grid on

%%

% The final position of the marble at the 20th data measurement is:
% x = -5.6250, y = 4.2188, z=-6.0938.
disp(marble_pos(20,:));

