ORDER OF PROCESSING: 



## Prepare files

1. download_and_convert_dicoms.sh 
2. process_nifti.py 
3. geometric_averages.py 
4. create_masks.py


## In detail

1. download_and_convert_dicoms.sh - fetch dicoms from BCH scanner. Ignore if nrrd/nifti files already available. To run - open this file and run according to instructions. 
2. process_nifti.py -f <NIFTI> - Convert a 4D diffusion mosaic file (in nifti format) into individual 3D files. Required for all IVIM methods to run. 4D diffusion mosaic is an output of DCM2NIIX conversion process (i.e. output of download_and_convert_dicoms.sh step) 
3. geometric_averages.py -d <DIRECTORY> - geometrically average multiple repetitions of each b-value. Required for all IVIM methods to run. 
4. create_masks.py -d <DIRECTORY> - create automatic mask of the abdomen or brain. If using custom mask - ignore this script. 

Read header of each .py file if need more information

## Helper tools 

- x2y.py - convert one file format to another for entire folder 
- create_mask.py - create mask for a specific file 
- fix_bval_file.py - fixes .bval file if certain low bvalues were set to zero according a .dvs file
- svtools.py - helper tools - e.g. file conversion and execution of bash commands.
