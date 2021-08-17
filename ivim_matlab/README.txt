To process one slice inside matlab: 
- process_ivim_whole_slice.m

To process multiple slices (via a CRL server and without entering matlab manually):
- process_ivim_multiple_slices.sh

To plot single voxel: 
- plot_ivim_voxel2.m



Warning: 
Currently this software will only run on CRL computers because of certain dependencies that are being imported from Moti's compiled binaries folders. In the future these need to be copied locally to this directory to make this independent. For now, you must add the following to your bash profile: 
export NLOPT_LIB=/home/ch169807/moti/nlopt-2.4.1/build/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NLOPT_LIB

And there are the associated libraries: 
addpath('/home/ch169807/moti/nlopt-2.4.1/matlab/')
addpath('/home/ch169807/Software/imrender/vgg/') - note: Im not sure if this lib is used in current code. The path is inherited from Sila. 

