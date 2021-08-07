function data = gaussianiir3d(data, sigma, numsteps)
%GAUSSIANIIR3D  Fast 3D Gaussian convolution IIR approximation
%   data = GAUSSIANIIR3D(data, sigma) convolves data with an approximation
%   of a Gaussian with standard deviation sigma.  The routine uses the fast
%   Gaussian convolution algorithm of Alvarez and Mazorra, where the 
%   Gaussian is approximated by a cascade of first-order infinite impulsive 
%   response (IIR) filters.  Boundaries are handled with half-sample 
%   symmetric extension.
%
%   GAUSSIANIIR3D(data, sigma, numsteps) specifies the number of steps 
%   (default 4).  Using more steps increases the accuracy but also the 
%   computation time.  The run time is linear in numsteps and independent 
%   of sigma.
%   
%   Reference:
%   Alvarez, Mazorra, "Signal and Image Restoration using Shock Filters and
%   Anisotropic Diffusion," SIAM J. on Numerical Analysis, vol. 31, no. 2, 
%   pp. 590-605, 1994.
% 
%   This program is free software: you can redistribute it and/or modify it
%   under, at your option, the terms of the GNU General Public License as 
%   published by the Free Software Foundation, either version 3 of the 
%   License, or (at your option) any later version, or the terms of the 
%   simplified BSD license.
% 
%   You should have received a copy of these licenses along with this 
%   program.  If not, see <http://www.gnu.org/licenses/> and
%   <http://www.opensource.org/licenses/bsd-license.html>.

% Pascal Getreuer 2011

if nargin < 3
    if nargin < 2
        error('Not enough input arguments.');
    end
    
    numsteps = 4;
end

shape = size(data);
data = data(:,:,:,:);
[N1,N2,N3,N4] = size(data); %#ok<NASGU>

lambda = double(sigma)^2/(2*numsteps);
nu = (1 + 2*lambda - sqrt(1 + 4*lambda))/(2*lambda);
boundaryscale = 1/(1 - nu);

for step = 1:numsteps
    % Filter along first dimension
    data = filter(1, [1,-nu], data, (boundaryscale - 1)*data(1,:,:,:), 1);
    data(N1:-1:1,:,:,:) = filter(1, [1,-nu], data(N1:-1:1,:,:,:), ...
        (boundaryscale - 1)*data(N1,:,:,:), 1);
    % Filter along second dimension
    data = filter(1, [1,-nu], data, ...
        (boundaryscale - 1)*permute(data(:,1,:,:),[2,1,3,4]), 2);
    data(:,N2:-1:1,:,:) = filter(1, [1,-nu], data(:,N2:-1:1,:,:), ...
        (boundaryscale - 1)*permute(data(:,N2,:,:),[2,1,3,4]), 2);
    % Filter along third dimension
    data = filter(1, [1,-nu], data, ...
        (boundaryscale - 1)*permute(data(:,:,1,:),[3,1,2,4]), 3);
    data(:,:,N3:-1:1,:) = filter(1, [1,-nu], data(:,:,N3:-1:1,:), ...
        (boundaryscale - 1)*permute(data(:,:,N3,:),[3,1,2,4]), 3);
end

data = ((nu/lambda)^(3*numsteps))*data; % Post scaling
data = reshape(data, shape);            % Restore original shape
