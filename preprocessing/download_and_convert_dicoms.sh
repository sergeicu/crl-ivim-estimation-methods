# PURPOSE: Download reconstructed DWI images from the scanner in DICOM format, then convert them to NIFTI format

# Step 1 - download DICOMs from server using Patient MRN and DATE of Acquisition 
MRN=
DATE=
savedir=
bash retrieve2.sh $MRN $DATE $savedir

# Step 2 - convert DICOM files into NIFTI - perform this on EACH individual DICOM directory that contains DWI files (i.e. scandir)
scandir=
cd $savedir
niidir=$scandir/nii
mkdir $scandir/nii
/opt/el7/pkgs/dcm2niix/dcm2niix -o nii/$scandir  $scandir

# Step 3 - check .bval files in each newly created `niidir` and correct the values manually if necessary [e.g. the new scanner labels all bvalues less than '50', as '0' in the .bval file and this needs to be corrected manually at this stage]
cat $(ls ${scandir}/nii/*.bval) 



### 
# WARNING: The following functionality is deprecated - as this produces files that are not ordered correctly
###

# Step 4 - convert to DICOM to NRRD
mkdir $scandir/nrrd
/opt/el7/pkgs/crlDcm/crlDcmConvert -f -r -e nrrd --DWIStacks 3D-Set $scandir nrrd




