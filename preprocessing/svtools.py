import subprocess
import os 
import nrrd 

import SimpleITK as sitk


# -----------
# Execute in bash 
# -----------


def execute(cmd,sudo=False):
    """Execute commands in bash and print output to stdout directly"""

    if sudo:
        cmd = ["sudo"]+cmd
    with subprocess.Popen(cmd, stdout=subprocess.PIPE, bufsize=1, universal_newlines=True) as p:
        for line in p.stdout:
            print(line, end='') # process line here

    if p.returncode != 0:
        raise subprocess.CalledProcessError(p.returncode, p.args)
        
# -----------
# File conversion 
# -----------

def svconvert(file,newformat, verbose=True, skip_existing=False):

    """Convert between MRI formats: nrrd, nii, vtk"""

    # check if format is correct 
    formats=[".nrrd", ".nii.gz", ".nii", ".vtk"]
    newformat = "." + newformat if not newformat.startswith(".") else newformat
    assert newformat in formats, f"Incorrect conversion format: {newformat}. Only accept: {formats}"

    # check file 
    assert os.path.exists(file), f"File does not exist: {file}"

    # output 
    base, ext = os.path.splitext(file)
    if ext == '.gz':
        base = file.replace(".nii.gz", "")
        ext = ".nii.gz"

    # assert extension 
    assert ext in formats, f"Incorrect extension fetched: {ext}. Allowed formats: {formats}"

    # read 
    img = sitk.ReadImage(file)

    # write 
    newfile=file.replace(ext, newformat)
    if os.path.exists(newfile) and skip_existing:
        print(f"File already exists, skipping")
    else:
        sitk.WriteImage(img,newfile)

        if verbose:
            print(f"Converted: {file} to {newformat}")
        

