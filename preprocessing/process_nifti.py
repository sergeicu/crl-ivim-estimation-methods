"""Convert a 4D diffusion mosaic (nifti) file into individual 3D files. 

    The 4D diffusion mosaic input file must be an output from DCM2NIIX conversion process, and must have a corresponding .bval file with the same name.

    Note that the .bval file CAN have randomly ordered b-values (e.g. 0 0 0 100 100 100 200 200 200 50 50 50 600 600 600 is OKAY). 
    
    However, you must ensure that the b-values listed in .bval file are CORRECT values. The new 3T scanner sometimes lists low b-values (e.g. b=20) as '0' in the .bval file. Therefore .bval file may need to be edited manually. There may be a script available later which corrects .bval automatically (however this has not yet been completed).

    The output 3D files are created in the correct naming convention for further processing. 
    e.g. b50#_2.nii.gz - where 50 refers to b-value and 2 refers to direction.
        
    Usage: 
        python fixing_nifti.py -f <filepath> -d <# of diffusion directions>
    
"""


import argparse
import os 
import numpy as np
import nibabel as nb 
from collections import Counter 

def load_args():
    
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file',type=str, required = True, help='full paths to directories to be processed')
    parser.add_argument('-d','--directions',type=int,default = 6, help='directions for bval')
    args = parser.parse_args()
    
    return args
        
        

def main():
    
    # load input arguments
    args = load_args()
    
    im = args.file
    
    # perform basic checks
    assert os.path.exists(im)
    assert im.endswith(".nii") or im.endswith(".nii.gz"), "Please provide path to a .nii or .nii.gz file"
    
    # get bvector 
    bval_path = im.replace(".nii", ".bval") if im.endswith(".nii") else im.replace(".nii.gz", ".bval")
    assert os.path.exists(bval_path), f"Corresponding .bval files does not exist {bval_path}"
    bvals = get_bvector(bval_path)

    # convert nifti file 
    convert_4D_to_3D(im, bvals, args.directions)    
    
    

def get_bvector(bval_path):
    """
    Obtain a list of bvecs from a .bval file produced as output of dcm2niix conversion
    
    """
    
    with open(bval_path) as f:
        line = f.readline()

    bvals = line.split(' ')
    bvals[-1] = bvals[-1][:-1]
    bvals = [int(i) for i in bvals]

    return bvals
    
def convert_4D_to_3D(impath, original_bvals, directions):
    
    """Convert a 4D diffusion mosaic into individual 3D files. 
    
    4D diffusion mosaic is an output of DCM2NIIX conversion process. 
        
    We submit a correct set of b-values that were given to the scanner at scan time. 
    
    
    WARNING: this process assumes that the ordering of b-values is correct. To check this - please read the following output file that is produced by DCM2NIIX process: <outputname>.bval. You may also want to verify that <outputname>.bvec corresponds to the original bvector file given to the scanner at scan time (e.g. such .txt file could have been produced by a script like this one - /home/ch215616/w/code/ivim/experiments/s20210317-ground-truth-scan/scan_prep/correctDiffusionDirections_modified2.m)
    )
    
    Args: 
        imagepath (str): full path to .nii file produced by the DCM2NIIX process 
        original_bvalues (list): list of integers denoting the FULL list of bvalues that correspond to the list of bvectors given to the scanner. E.g. if there were 8 b-values and 6 directions for each, this will be a list of length 8*6 (assuming that the first bvalue, such as b0, was acquired 6 times)
        
    
    
    """
    assert os.path.exists(impath)
    imo = nb.load(impath)
    im = imo.get_fdata()
    
    dirname = os.path.dirname(impath)
    dirname = dirname + "/" if dirname else ''

    original_vector = original_bvals
        
    assert len(original_vector) == imo.shape[-1], "length of the original vector must be the same as the image produced by the dcm2nii converter"
    
    # initiate counter to keep track of how many times a particular b-value has been seen (so that we can increment directions)
    c = Counter()

    # build new header (require to decrease the number of directions in t) - this will be the same for all files 
    header = imo.header 
    header['dim'][4] = 1 

    # cycle through each individual file
    for i in range(0,len(original_vector)):

        # get individual image that represents single bvalues and single direction
        im_singleBval_singleDir = im[:,:,:,i]

        # extract bvalue number 
        bvalnum = original_vector[i]    

        # extract the direction number (direction is equal to the number of times that a particular bvalue has already been seen - starting from zero)
        # for reference see the following file - ~/w/code/ivim/2020/brain_ivim/fetch_dicoms.py
        directionnum = c[bvalnum]
        c[bvalnum] += 1  # increment counter 


        # save this image into separate file  in the following format: b<bvalnum>#_<directionnum>.nii.gz 
        savename = dirname + 'b'+str(bvalnum)+"#_"+str(directionnum)+ ".nii.gz"

        # make a nifti image and save
        imnewo = nb.Nifti1Image(im_singleBval_singleDir,affine=imo.affine, header=header)
        nb.save(imnewo, savename)
        # print progress
        print(savename)        

    
    
    
if __name__=='__main__':
    
    
    main()    
    
