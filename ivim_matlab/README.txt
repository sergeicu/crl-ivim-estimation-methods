## Quick start: 

To process one slice in matlab: 
- process_ivim_whole_slice.m

To plot single voxel in matlab: 
- plot_ivim_voxel2.m


## Example - compute multiple slices:


Inside matlab: 

```
% initialize directory 
cd <path_to_code_dir>
addpath(genpath('crl-ivim-estimation-methods'))

% initialize common variables (to all slices)
directory= '<path to /averaged/ directory>';
bvalsFileNames_textfile=[directory, 'bvalsFileNames_average.txt'];
savedir='<full path to directory where results will be saved>';

% compute for the following slices
for slice=35:45
    process_ivim_whole_slice(bvalsFileNames_textfile, savedir, slice)
end 

% print directory contents) 
disp("FINISHED!")
ls(savedir)

```



## Example - compute voxel and plot:


Inside matlab: 

```

% initialize directory 
cd <path_to_code_dir>
addpath(genpath('crl-ivim-estimation-methods'))

% initialize common variables (to all slices)
directory= '<path to /averaged/ directory>';
bvalsFileNames_textfile=[directory, 'bvalsFileNames_average.txt'];
savedir='<full path to directory where results will be saved>';

bthresh = 150; % default threshold value to use for segmented IVIM fit 
scanname = 'patient 1';  % a scan name that you would like to use 

% compute for KIDNEYS 
roi = 'kidneys'; %roi name that you are plotting 
voxel = [62,89,32];
plot_ivim_voxel2(bvalsFileNames_textfile, voxel(1), voxel(2), voxel(3), scanname , roi ,bthresh)

```


## Setup 

Warning: 
You must add the following to your bash profile: 
export NLOPT_LIB=/home/ch169807/moti/nlopt-2.4.1/build/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NLOPT_LIB

In the future these library dependencies (from Moti) need to be copied locally to this github repo as a docker image that can be spun. 

These are the associated libraries that need to be compiled: 
addpath('/home/ch169807/moti/nlopt-2.4.1/matlab/') 
addpath('/home/ch169807/Software/imrender/vgg/') 

