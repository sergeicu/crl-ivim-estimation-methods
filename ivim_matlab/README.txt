To process one slice inside matlab: 
- serge_ivim_whole_slice.m

To process multiple slices (via a CRL server and without entering matlab manually):
- process_ivim_multiple_slices

To plot single voxel: 
- TBC (to be completed) plot_ivim_voxel.m



Warning: 
Currently this software will only run on CRL computers because of certain dependencies that are being imported from Moti's storage. In the future these need to be copied locally to this directory. 
These libs are: 
addpath('/home/ch169807/moti/nlopt-2.4.1/matlab/')
addpath('/home/ch169807/Software/imrender/vgg/') - note: Im not sure if this lib is used in current code. The path is inherited from Sila. 
