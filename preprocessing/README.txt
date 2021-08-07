ORDER OF PROCESSING: 


###
Prepare files
###
1. download_and_convert_dicoms.sh 
2. process_nifti.py 
3. geometric_averages.py 
4. create_masks.py

### 
Instructions
###
1. download_and_convert_dicoms.sh - open this file and run according to instructions
2. process_nifti.py -f <NIFTI>
3. geometric_averages.py -d <DIRECTORY>
4. create_masks.py -d <DIRECTORY>

Read header of each .py file if need more information

###
Helper tools 
###
- [tbc] x2y.py - convert one file format to another for entire folder 
- [tbc] create_mask.py - create mask for a specific file 
- [tbc] fix_bval_file.py - fixes .bval file if certain low bvalues were set to zero according a .dvs file