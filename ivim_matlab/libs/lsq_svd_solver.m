function c=lsq_svd_solver(A,b)

% disp('Solving least squares problem with SVD')
% Compute the SVD of A
[U S V] = svd(A);
% find number of nonzero singular value = rank(A)
r = length(find(diag(S)));
Uhat = U(:,1:r);
Shat = S(1:r,1:r);
z = Shat\Uhat'*b;
% or
%z = Uhat'*y./diag(Shat);
c = V*z;
