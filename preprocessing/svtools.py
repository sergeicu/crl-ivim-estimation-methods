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

def crl_convert_format(image, format_out,dirout=None, verbose = True,debug=False): 
    """
    Python wrapper for crlConvertBetweenFileFormats that converts between .nrrd, .nii.gz, .vtk 
    Args: 
        image (str):      path to image 
        format_out (str): enum to .nrrd, .vtk, .nii.gz, .nii
        [dirout] (str):   convert into a specific directory 
        [verbose] (str):  print the command being executed 
    Returns: 
        str: Path to converted file 
    """    
    """py wrapper for crlConvertBetweenFileFormats tool"""
    
    crlConvertFormat="/opt/el7/pkgs/crkit/2021/crkit-master/bin/crlConvertBetweenFileFormats"
    
    # explicitly search for the format_in (to avoid errors like before)
    if image.endswith('.nii.gz'):
        format_in = '.nii.gz'
    elif image.endswith('.nii'):
        format_in = '.nii'
    elif image.endswith('.nrrd'):
        format_in = '.nrrd'
    elif image.endswith('.vtk'):
        format_in = '.vtk'
    else: 
        print("FILE FORMAT IS WRONG")
    if dirout: 
        dirout = dirout+'/' if not dirout.endswith('/') else dirout
        d,f = os.path.split(image)
        imageout=dirout+f
    else:
        imageout=image
    #cmd = [crlConvertFormat, "-in", image, "-out", imageout.replace(format_in, format_out)]
    cmd = [crlConvertFormat, image, imageout.replace(format_in, format_out)]
    if debug: 
        print(" ".join(cmd))
    if verbose:
        print(f"converting: {image} from {format_in} to {format_out}")
    #subprocess.call(cmd,stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    execute(cmd)
    return imageout.replace(format_in, format_out)
