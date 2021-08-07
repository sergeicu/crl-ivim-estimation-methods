function r = ricernd(v, s)
%   r = ricernd(v, s) returns random sample(s) from the Rice (aka Rician) 
%   distribution with parameters v and s.
%   (either v or s may be arrays, if both are, they must match in size)
% s=5; % noise level (NB actual Rician stdev depends on signal, see ricestat)
% im_g = im + 5 * randn(size(im)); % *Add* Gaussian noise
% im_r = ricernd(im, s);% *Add* Rician noise
x = s .* randn(dim) + v;
y = s .* randn(dim);
r = sqrt(x.^2 + y.^2);