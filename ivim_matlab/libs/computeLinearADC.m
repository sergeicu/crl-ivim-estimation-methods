function [initial_adc,initial_b0]=computeLinearADC(bvals, signal )
% ****************** FOR 3 or more independent bvalues (siemens) *********************
% linear model
A(:,1) = -bvals;
A(:,2) = ones(size(bvals));

b = log(double(signal));

A=double(A);

x = lsq_svd_solver(A,b);
initial_adc = max(x(1),0);
initial_b0 = exp(min(x(2),6.5));