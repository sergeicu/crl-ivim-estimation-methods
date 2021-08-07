"""This file compues geometric averages between different directions of each acquired b-value. 

    B-value files must be in the correct format - e.g. b0#_0.nii.gz, b0#_1.nii.gz, .. b50#_5.nii.gz,..

    The output is saved to /averaged/ folder in the same directory where b-value files are found. 
    
    Additionally, two .txt files are created - bvalsFilenames.txt and /averaged/bvalsFilenames_averaged.txt. 
    Important: the paths to b-value files in each .txt file are absolute. To change this, use '-noabsolute' flag when specifying input to this function 
    
    
    Usage: 
    
        python geometric_averages.py --d <directory path(s)> 
        python geometric_averages.py --d <directory path(s)> --noabsolute


"""

import glob 
import os 
import re 
import argparse
import subprocess 
import shutil 
import sys 
from collections import Counter 

import svtools as sv

    
def load_args():
    
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--directories',type=str,nargs='+', required = True, help='full paths to directories to be processed')
    parser.add_argument('--noabsolute',action="store_true",help='if used, the paths of b-value files written to .txt files will be relative, not absolute')    
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
    files = glob.glob(path + "*b[0-9]*#*[0-9].nii.gz")
    assert files, f"no files found of the correct format are not given in correct format - must be b0#_2.nii.gz and similar. Files found are {files}"
    
    # check how to save bval filepaths 
    filepaths_type = 'relative' if args.noabsolute else 'absolute'
    
    # Create .txt files for processing geometric averages
    write_bvalsFileNames(args,filepaths_type)

    # Create geometric averages
    bvalfilenames = path+"bvalsFileNames.txt" 
    outputdir = path+"averaged/"
    os.makedirs(outputdir, exist_ok=True)
    geometric_average(bvalfilenames,outputdir)
    
    # Convert .vtk files to .nrrd in '/averages/' directory 
    vtk2nrrd(outputdir)    
    
    # Save a .txt file with paths to geometrically averaged files
    bvals = get_bvals(outputdir)
    savedir = write_bvalsFileNames_average(outputdir, bvals,filepaths_type)
    
    print(f"Saved results to {savedir}")
    
    


def natural_sort(l): 
    
    """Helper funciton - performs natural sort of a list 
    e.g. 
    [s1.nii.gz, s2.nii.gz,s10.nii.gz]
    instead of 
    [s1.nii.gz, s10.nii.gz, s2.nii.gz]
    """
    
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [convert(c) for c in re.split('([0-9]+)', key)]
    return sorted(l, key=alphanum_key)

def vtk2nrrd(outputdir):
    
    """Converts all .vtk files in (geometrically) '/averaged/' directory to .nrrd format 
    
    This functionality is necessary for more recent IVIM estimation methods (2D CNN, 1D FCN, etc).
    """
    
    # get list of files
    files = glob.glob(outputdir + "/b*.vtk")
    assert files 
    
    # convert each file 
    for file in files:
        
        if not os.path.exists(file.replace(".vtk", ".nrrd")):
            sv.crl_convert_format(file,".nrrd")
    



def get_bvals(path, filetype=".vtk"):
    
    """Get list of bvalues from filenames"""
    
    files = glob.glob(path + "/*" + filetype)

    
    # numbers 
    files = natural_sort(files)    
    bvals = []
    for f in files:
        f = os.path.basename(f)
        bvals.append(int("".join([i for i in f if i.isdigit()])))
    
    return bvals
    
    


def check_if_nifti(scandir):
    """ Check if files are in .nii.gz format. If yes - convert them to .nrrd. 
    Required for geometric averaging script """
    
    files = glob.glob(scandir+'b*.nii.gz')
    if files:
        print("Files are in .nii.gz format. Converting to .nrrd....")
        for f in files: 
            if not os.path.exists(f.replace(".nii.gz", ".nrrd")):
                sv.crl_convert_format(f, ".nrrd")
        files = [f.replace(".nii.gz", ".nrrd") for f in files]

    assert files, f"No .nrrd files are found of the correct format in this directory. Files must be b0#_1.nrrd format. Check your files here: {scandir}"    

    return files 

def write_bvalsFileNames(scandir,filepaths_type='absolute'): 
    """Creates a .txt file for performing geometric averaging operation"""
    
    # get filenames
    scandir = scandir + '/' if not scandir.endswith('/') else scandir 
    # fetch only the files that start with 'b'
    files = glob.glob(scandir+'b*.nrrd')
    if not files:
        # check if files are in .nii.gz format - then convert them 
        files = check_if_nifti(scandir)
    files = [os.path.basename(file) for file in files]
    files = sorted(files)
    
    # create a new file name
    savename = scandir+'bvalsFileNames.txt'    
    if os.path.exists(savename):
        # remove the file before writing 
        os.remove(savename)
    
    # open file and write 
    lines = []
    with open(savename,'w') as t:
        for file in files: 
            # extract bvalue 
            bval_str = re.search(r"b[0-9]*",file).group()
            bval = int(bval_str[1:])
            
            if filepaths_type == 'absolute':
                # get line 
                lines.append(' '.join([str(bval),scandir+file+"\n"]))
            else: 
                lines.append(' '.join([str(bval),file+"\n"]))
        t.writelines(lines)            
    print(f"Result saved to: {savename}")

    
   
    
def geometric_average(bvalfilenames,outputdir):
    """Performs geometric averaging of b-values given a .txt input file"""
    
    
    func = "/fileserver/abd/bin/averageBVals"
    
    # get number of entries in the .txt file 
    with open(bvalfilenames, 'r') as f: 
        lines = f.readlines()
    N = len(lines) 
    cmd = [func,"-i",bvalfilenames,"-o",outputdir, "-n", str(N), "-m", "geometric"]
    
    # prompt the user if files already exist whether to execute or not
    if glob.glob(outputdir+"*.vtk"):
        answer = input(f"\nWARNING: geometric average files have already been computed. Do you want to recompute?\n{outputdir}\n Type 'Y' or 'N'\n")
        if answer.lower() == 'n':
            return 
    sv.execute(cmd) 
        


def write_bvalsFileNames_average(signaldir, bvals, extension='.vtk', filepaths_type='absolute'):
    # source: svtools library 
    """create bvalFilenames_average .txt files required for running IVIM analysis
    
    Args: 
        signaldir (str): path to directory which contains the acquired b-value files (whether geometrically averaged or not) in the form 'b0_averaged.vtk', etc 
        bvals (list): list of bvalues as integers 
        extension (str): specify whether the filesnames are .nrrd or .vtk (default)
    Returns: 
        savedir (str): directory to which the bvalsFileNames.txt file was saved. 

    WARNING: .txt file will be saved to the same directory where the averaged images are stored 
    NB Advanced user warning: this is different to bvalsFilename.txt which is required to run geometric averaging operation. Do not confused the two. 

    
    """
    savedir = signaldir + "/bvalsFileNames_average.txt"
    lines = []
    
    if os.path.exists(savedir):
        answer = input(f"\nWARNING: geometric averages .txt file already exists. Do you want to overwrite this file?\n{savedir}\n Type 'Y' or 'N'\n")
        if answer.lower() == 'n':
            return savedir
    
    with open(savedir,'w') as f:
        for bval in bvals:
            
            if filepaths_type == 'absolute':
                # get line 
                fullpath=signaldir+"b"+str(bval)+"_averaged"+extension
            else: 
                fullpath="b"+str(bval)+"_averaged"+extension
            lines.append('\t'.join([str(bval),fullpath+"\n"]))
        f.writelines(lines) 
    return savedir        
        
        
if __name__=='__main__':
    

    main()
    
                     
           
                     