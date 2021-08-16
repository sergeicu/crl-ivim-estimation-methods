function xopt=computeIVIM_plot(bValsVec,signalVec)
% output: xopt: IVIM params: So, Dper, Dd,f
% Computes IVIM params using Nonlinear Least Squares, for the initialization, segmented least sqaures is used 
% Initial IVIM parameter estimation using the method from the paper: "Comparison of Biexponential and Monoexponential 
% Model of Diffusion Weighted Imaging in Evaluation of Renal Lesions,
% Preliminary Experience", Investigative Radiology 2010.

% signalVec=squeeze(bImages(row,col,slice,:));

b_thresh=150;
%b_thresh=250; % old - updated on 20210716
linear_weights=ones(size(bValsVec));
linear_weights2=linear_weights(bValsVec>b_thresh);
linear_weights2=linear_weights2/sum(linear_weights);

% inital fit of ADC and intercept b0 from higher b values
signalVec=double(signalVec);
bValsVec=double(bValsVec);
signalVec2=signalVec(bValsVec>b_thresh);
bValsVec2=bValsVec(bValsVec>b_thresh);
signalVec2(signalVec2< eps)=0;


[initial_Dd,initial_b0]=computeLinearADC(bValsVec2, signalVec2);

modelB5 = initial_b0 * exp(-min(bValsVec)*initial_Dd);

t=double(bValsVec);
M=signalVec;
[st,inso]=sort(t);
shighb=(initial_b0)*exp(-initial_Dd.*st);
ln_s=log(initial_b0)-(initial_Dd).*st;
figure, plot(st,(M(inso)),'r'), hold on, plot(st,shighb,'b'),%hold on, plot(st,ln_sx,'m')


[~,in]=min(bValsVec);
meanSb0=mean(signalVec(in)*linear_weights(in));

initial_f = (meanSb0-modelB5)/meanSb0;
%%
if initial_f<0
    initial_f=0;
    initial_per=0;
    initial_full_B0= initial_b0;
    X=0;
else
    %just optimize for perfusion using nonlinear optimization
    params_init1(1)=initial_Dd*8;
    M = double(signalVec);
    opt.min_objective=@(params)(sum(M - meanSb0 *(initial_f*exp(-(bValsVec)*(initial_Dd+params(1)))...
    + (1-initial_f)* exp(-(bValsVec)*initial_Dd))).^2);
%     X = fminsearch(@(params) opt.min_objective(params),params_init1)
    clear lowerBoundParams upperBoundParams
    lowerBoundParams(1) = 0;%max(params_init1*0.25,0.0);
    upperBoundParams(1) = 0.02;%min(params_init1*1.75,0.008);

    opt.algorithm=NLOPT_LN_BOBYQA;
    opt.lower_bounds = lowerBoundParams;
    opt.upper_bounds = upperBoundParams;
    opt.maxeval = 200;
    opt.fc = {};

    [xopt, fmin, isSuccessful] = nlopt_optimize(opt, params_init1);
    X=xopt;
end

% Optimize for all IVIM params using nonlinear least squares optimization 

params_in(1) = initial_b0;
params_in(2) = X;
params_in(3) = initial_Dd;
params_in(4) = initial_f;
IVIMfunction=@(params,bValsVec)(params(1)*(params(4)*exp(-(bValsVec)*(params(2)+params(3)))...
    + (1-params(4))* exp(-(bValsVec)*params(3))));
S=IVIMfunction(params_in,bValsVec);
params_in(2)=0.0;
Sinit=IVIMfunction(params_in,bValsVec,M);

hold on, plot(st,Sinit(inso),'k')

params_init2=params_in;
opt.min_objective=@(params,bValsVec,M)sum((M-params(1)*(params(4)*exp(-(bValsVec)*(params(2)+params(3)))...
     + (1-params(4))* exp(-(bValsVec)*params(3)))).^2);
params_out = fminsearch(@(params) opt.min_objective(params,bValsVec,M),params_init2)
Sf=IVIMfunction(params_out,bValsVec,M);
plot(st,(Sf(inso)),'g'), hold on,
lowerBoundParams(1) = max(params_init2(1)*0.25,0.0);
lowerBoundParams(2) = max(params_init2(2)*0.25,0.0);
lowerBoundParams(3) = max(params_init2(3)*0.25,0.0);
lowerBoundParams(4) = max(params_init2(4)*0.25,0.0);
upperBoundParams(1) = min(params_init2(1)*1.75,1000.0);
upperBoundParams(2) = min(params_init2(2)*1.75,1000.0);
upperBoundParams(3) = min(params_init2(3)*1.75,1000.0);
upperBoundParams(4) = min(params_init2(4)*1.75,1000.0);

opt.min_objective=@(params)sum((M-params(1)*(params(4)*exp(-(bValsVec)*(params(2)+params(3)))...
     + (1-params(4))* exp(-(bValsVec)*params(3)))).^2);

opt.algorithm=NLOPT_LN_BOBYQA;
opt.lower_bounds = lowerBoundParams;
opt.upper_bounds = upperBoundParams;
opt.maxeval = 100;
opt.fc = {};

[xopt, fmin, isSuccessful] = nlopt_optimize(opt, params_init2);
S=IVIMfunction(xopt,bValsVec);

params_in(2)=0.0;
Sinit=IVIMfunction(params_in,bValsVec,M);
plot(st,(M(inso)),'r'), hold on, plot(st,shighb,'b'),hold on, plot(st,S(inso),'m')