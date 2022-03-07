# PURPOSE: Download reconstructed DWI images from the scanner in DICOM format, then convert them to NIFTI format

# Step 1 - download DICOMs from BCH scanners using Patient MRN and DATE of Acquisition 
MRN=<patient_MRN>
DATE=<YYYYMMDD>
savedir=<path_to_save_files_to>
bash retrieve2.sh $MRN $DATE $savedir

# Step 2 - convert DICOM files into NIFTI - perform this on EACH individual DICOM directory that contains DWI files (i.e. scandir)
scandir=<path_to_scandir_with_dicoms_for_DWI_scan>
cd $savedir
niidir=$scandir/nii
mkdir $scandir/nii
/opt/el7/pkgs/dcm2niix/dcm2niix -o $scandir/nii/  $scandir

# Step 3 - check .bval files in each newly created `niidir` and correct the values manually if necessary [e.g. the new scanner labels all bvalues less than '50', as '0' in the .bval file and this needs to be corrected manually at this stage]
cat $(ls ${scandir}/nii/*.bval) 

