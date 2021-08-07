function process_ivim_whole_slice(bvalsFileNames_textfile, savedir, slice)

% Verbose 
disp('Computing slice')
disp(slice)
disp('for')
disp(bvalsFileNames_textfile)
disp('with output saved to')
disp(savedir)

% import libraries 
addpath(genpath('libs'))

% check if given files exist 
if ~exist(savedir, 'dir')
    msg = 'Savedir does not exist. Please check inputs';
    error(msg)
end 
if ~exist(bvalsFileNames_textfile, 'file')
    msg = 'bvalsFileNames does not exist. Please check inputs';
    error(msg)
end 
if ~endsWith(bvalsFileNames_textfile, '.txt')
    msg = 'bvalsFileNames needs to end with .txt extension. Please check inputs';
    error(msg)
end 



% read text file with image paths
fid = fopen(bvalsFileNames_textfile);
C = textscan(fid, '%d%s');
fclose(fid);


% read vtk images
NumOfImages=length(C{1});
bvalueImageFileNames=C{2};
bValsVec=C{1};
[~,sp,orig,~]=readVTK([bvalueImageFileNames{1}]); 
for i=1:NumOfImages
    if ~exist(bvalueImageFileNames{i}, 'file')
        msg = 'vtk image does not exist. Please check bvalueImageFileNames text file for correct paths';
        error(msg)
    end 
   [bImages(:,:,:,i),sp,orig,~]=readVTK([bvalueImageFileNames{i}]); 
end


% Initizalize output images
imageSize=size(squeeze(bImages(:,:,:,1)));
b0=zeros(imageSize);
dstar=zeros(imageSize);
adc=zeros(imageSize);
f=zeros(imageSize);
[nrows, ncols, nslice]=size(squeeze(bImages(:,:,:,1)));

% check if total slice numberes match
if slice>nslice
        disp(slice)
        disp(nslice)
        msg = 'the slice number provided is larger than total number of slices';
        error(msg)
end 



% init params
nCores=7; 
isML=0;

% check if slice already been processed (and skip)
S0_saved= [savedir, '/D_sl', num2str(slice), '.vtk']
if exist(S0_saved, 'file')
    disp('Output file for this slice already exist. Please delete/move the file and re-run the script if necessary')
    disp(S0_saved)
    disp('..exiting..')
    exit
else

% compute ivim parameters with matlab 
parfor row=1:nrows
    for col=1:ncols
        xopt=computeIVIM_silent(bValsVec,squeeze(bImages(row,col,slice,:)));
        b0(row,col,slice)=xopt(1);
        dstar(row,col,slice)=xopt(2);
        adc(row,col,slice)=xopt(3);
        f(row,col,slice)=xopt(4);        
    end 
end 


% remove zeros and nans
b0(isnan(b0))= 0;
adc(isnan(adc))= 0;
dstar(isnan(dstar))= 0;
f(isnan(f))= 0;

b0(isinf(b0))= 0;
adc(isinf(adc))= 0;
dstar(isinf(dstar))= 0;
f(isinf(f))= 0;

b0((b0<0))=0;
adc((adc<0))=0;
dstar((dstar<0))=0;
f((f<0))=0;

%save to file
writeVTK(adc, [savedir, '/D_sl', num2str(slice), '.vtk']);
writeVTK(b0, [savedir, '/S0_sl', num2str(slice),'.vtk']);
writeVTK(dstar, [savedir, '/Dstar_sl', num2str(slice),'.vtk']);
writeVTK(f, [savedir, '/f_sl', num2str(slice),'.vtk']);


end


function [adc,b0]=computeLinearADC(bvals, signal)
% ****************** FOR 3 or more independent bvalues (siemens) *********************
% linear model
A(:,1) = -bvals;
A(:,2) = ones(size(bvals));
b = log(double(signal));

A=double(A);

x = lsq_svd_solver(A,b);
adc = x(1);
b0 = exp(x(2));





function computeTwoPointsADC(bvals, signal)
% ****************** FOR 2 bvalues (ge) *********************
%  assume that bvals(1) = 0 and bvals(2) = bvalue
b0 = signal(1);
diff = log(signal(2)) - log(signal(1));
slope = diff/(bvals(1)-bvals(2));
adc = slope;



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



	
function [adc,b0]=computeMLADC(bval, signal, b_variance,adc,b0)
    
% params (1) = b0;
% params (2) = adc;

params_init=[261.2901  0.0029]*1.1;
scales(1) = 1;
scales(2) = 1000000;
params_init.*scales

params_init=[b01 adc1]

lowerBoundParams(1) = max(b01*0.25,0.0);
lowerBoundParams(2) = max(adc1*0.25,0.0);
upperBoundParams(1) = min(b01*1.75,1000.0);
upperBoundParams(2) = min(adc1*1.75,1.0);

% opt.min_objective = @(params) ADCMLECostFunction(params,bval,signal,b_variance');
opt.min_objective = @(params) ADCMLECostFunction(params);

opt.algorithm=NLOPT_LN_BOBYQA;
opt.lower_bounds = lowerBoundParams;
opt.upper_bounds = upperBoundParams;
opt.maxeval = 200;
opt.fc = {};


% bval= double([100, 200, 270, 400, 50, 5, 600, 800])';
% signal=double([206, 191, 73, 63, 230,294,55,27])';
signal=squeeze(bImages(row,col,slice,:));
bval=bValsVec;
% b_variance =[8.7694    9.7226    7.3968    8.1613    7.6541    7.7605    7.4123    7.3570]';
b_variance=varianceVec;
M = double(signal);
Var = b_variance.^2;
opt.min_objective=@(params)sum(log(besseli(0,(params(1)*exp(-double(bval).*double(params (2))).*M./Var),1))+(params(1)*exp(-double(bval).*double(params (2)))).^2./(2*Var));
opt.min_objective=@(params)sum(log(besseli(0,(params(1)*exp(-double(bval).*double(params (2))).*M./Var),1))+(params(1)*exp(-double(bval).*double(params (2))).*M./Var)-(params(1)*exp(-double(bval).*double(params (2)))).^2./(2*Var));

opt.min_objective=@(params)ADCMLECostFunction_2(params)

[xopt, fmin, isSuccessful] = nlopt_optimize(opt, params_init.*scales)
ml_params=xopt/scales;
if (isSuccessful )
    b0 = ml_params(1);
    adc = ml_params(2);
else
    display('optimizer error');
end
[x,fval,exitflag] = fminsearch(opt.min_objective, params_init,optimset('TolX',1e-8))
aa=params_init.*scales+rand(1,2)*2;
 X = fminsearch(@(params) opt.min_objective(params),aa)
function likelihoodVal= ADCMLECostFunction(params,bval,signal,b_variance)
% Likelihood terms of Rician distribution. The terms that are independent
% of S are omitted
% ln(L(adc,SO,M,Var): sum_i log( besseli(0,(S.*M)./Var)) 
%                     - sum_i (S^2/(2*Var)) +SM/Var
s0  = params(1);
DiffCoeff = params (2);

M = signal;
S = s0*exp(-bval.*(DiffCoeff));
Var = b_variance.^2;
val1 = log (besseli(0,(S.*M)./Var)) +  ((S.*M)./Var);
val2 = (S.^2)/(2*Var);

likelihoodVal = sum(val1) - sum(val2);



        