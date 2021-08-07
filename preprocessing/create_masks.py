"""Create advanced mask for an abdominal image - uses erosion, dilation, blurring of sharp edges and removal of objects

The mask is based on estimation of noise thresholds in the image and ensures that the mask is 'whole' (does not have holes in it). This 'whole' mask is necessary for deep learning based estimation methods in particular (and can also be used by non deep learning methods).

Mask is saved into the same folder as 'b0_averaged.nrrd' image. In default case this would be '/averaged/' folder

Please specify path to directory(-ies) where a '/averaged/b0_averaged.nrrd' file exists.

Usage: 
    python create_masks.py -d <directory>

"""

import os 
import glob 
import sys

import numpy as np 
import nrrd 
import cv2
from skimage import morphology

def load_args():
    
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--directories',type=str,nargs='+', required = True, help='full paths to directories to be processed')
    args = parser.parse_args()
    
    return args

def main():
    
    # load input args 
    args = load_args()
    
    # process list of dirs
    if isinstance(args.directories,list):
        for d in args.directories:
            process_dir(args,d)
    # process single dir
    else:
        process_dir(args,args.directories)
    
        
def process_dir(args,path):
    """Processes each directory"""
    
    # perform various checks 
    assert os.path.exists(path), f"path does not exist {path}"
    assert os.path.isdir(path), f"not a directory: {path}"
    path = path + "/"
    
    # get b0path
    b0path = path + "/averaged/b0_averaged.nrrd"
    if not os.path.exists(b0path):        
        # try to find b0path without the subdir
        b0path = path + "b0_averaged.nrrd"
    assert os.path.exists(b0path), f"No b0_averaged.nrrd file found. Please ensure that b0_averaged.nrrd exists in the supplied directory or in the subfolder /averaged/ of this same directory"
    
    # create and save mask
    process_b0_image(b0path, maskname = 'mask.nrrd', masktype='improved')
    
    
def process_b0_image(b0path, maskname = 'mask.nrrd', masktype=masktype):
    """Given a b0 image, create a mask"""
    

    # get directory name 
    dirname = os.path.dirname(b0path) + "/"

    # load b0 image 
    im,hdr = nrrd.read(b0path)

    # create mask 
    mask = create_mask(im, masktype)

    # save mask 
    savename = b0path.replace("b0_averaged.nrrd", maskname) 
    nrrd.write(savename, mask, header=hdr)
    
    print(f"Saved mask to: {savename}")



def create_mask(im, masktype='improved'):
    
    if masktype=='improved':
    
        # IMPROVED MASKING PROCESS
        # 1. Measure noise in the corners of the image
        # 2. Mask image by mean of noise (as threshold)
        # 3. Erode + Dilate 
        # 4. Add median blur to remove sharp edges
        # 5. Remove small objects + Remove small holes 

        # 1. Measure noise in the corners of the image
        corners = im[0:20,0:20,:]+im[-20:,-20:,:]   #+ref_im[-20:,0:20,:]+ref_im[0:20,-20:,:] -> not so great 
        threshold = np.mean(corners)#+np.std(corners)

        # 2. Mask image by mean of noise (as threshold)
        mask = np.zeros_like(im)
        mask[im>threshold] = 1 

        # 3. Erode + Dilate     
        kernel_erode = np.ones((3,3), np.uint8) 
        kernel_dilate = np.ones((3,3), np.uint8) 
        img_erosion = cv2.erode(mask, kernel_erode, iterations=1) 
        img_dilation = cv2.dilate(img_erosion, kernel_dilate, iterations=1) 

        # 4. Add median blur to remove sharp edges
        img_dilation = cv2.medianBlur(img_dilation,5)

        # 5. Remove small objects + Remove small holes 
        small_object_threshold = 2000 
        small_hole_threshold = 1000
        # NB must be done for each slice separately (else doesn't work)
        slices = img_dilation.shape[-1]
        for sl in range(0,slices): 
            im = img_dilation[:,:,sl]    
            arr = im > 0
            cleaned = morphology.remove_small_objects(arr, min_size=small_object_threshold)  # threshold 
            cleaned = morphology.remove_small_holes(cleaned, area_threshold=small_hole_threshold) # source https://stackoverflow.com/questions/55056456/failed-to-remove-noise-by-remove-small-objects    
            # put back into the mask
            mask[:,:,sl] = cleaned.astype(mask.dtype)
    
    elif masktype=='simple':
        threshold = 25
        
        mask = np.zeros_like(im)
        mask[im>threshold] = 1 

    elif masktype=='dummy':
        mask = np.ones_like(im)
        
    else: 
        sys.exit('mask type not recognised. Please supply correct mask type')
    
    return mask 
    
    
    

if __name__ == '__main__':

    main()
    
