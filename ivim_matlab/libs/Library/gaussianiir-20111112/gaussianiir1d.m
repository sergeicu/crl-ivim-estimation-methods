function data = gaussianiir1d(data, sigma, numsteps)
%GAUSSIANIIR1D  Fast 1D Gaussian convolution IIR approximation
%   data = GAUSSIANIIR1D(data, sigma) convolves data with an approximation
%   of a Gaussian with standard deviation sigma.  The routine uses the fast
%   Gaussian convolution algorithm of Alvarez and Mazorra, where the 
%   Gaussian is approximated by a cascade of first-order infinite impulsive 
%   response (IIR) filters.  Boundaries are handled with half-sample 
%   symmetric extension.
%
%   GAUSSIANIIR1D(data, sigma, numsteps) specifies the number of steps 
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
%   <http://www.opensource.org/licenses/bsd-license.html>

% Pascal Getreuer 2011

if nargin < 3
    if nargin < 2
        error('Not enough input arguments.');
    end
    
    numsteps = 4;
end

if numel(data) <= 1
    return;
end

shape = size(data);
N = shape(find(shape > 1, 1));
data = reshape(data, N, []);            % Reshape into 2D array with N rows

lambda = double(sigma)^2/(2*numsteps);
nu = (1 + 2*lambda - sqrt(1 + 4*lambda))/(2*lambda);
boundaryscale = 1/(1 - nu);

for step = 1:numsteps                   % Perform heat equation steps
    % Apply causal recursive filter
    data = filter(1, [1,-nu], data, (boundaryscale - 1)*data(1,:), 1);
    % Apply anticausal recursive filter
    data(N:-1:1,:,:) = filter(1, [1,-nu], data(N:-1:1,:), ...
        (boundaryscale - 1)*data(N,:,:),1);
end

data = ((nu/lambda)^numsteps)*data;     % Post scaling
data = reshape(data, shape);            % Restore original shape
