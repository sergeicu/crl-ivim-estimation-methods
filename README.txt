A collection of libraries for estimation of IVIM parameters. 

Start with: 
- preprocessing/README.txt 

Then: 
- choose a method to estimate IVIM

The following types of processing are available: 
- IVIM (BOBYQA) C++ 
- SCIM (BOBYQA) C++ 
- 1D FCN (Barbieri et al. 2020) 

Also available: 
- 2D CNN (Vasylechko et al.) - pre-trained model on abdominal DWI MRI for 7 b-values
- IVIM (BOBYQA) Matlab 
- DIPY

##############################
Notes on IVIM estimation methods
##############################


###
Matlab 
###
- IVIM (BOBYQA) method should be run on a CRL server instead of your own computer. 
- Matlab is processing one slice at a time. After computing 'all slices', there is an option to merge files together.
- SCIM / SPIM methods (Kurugol et al) is also available in Matlab, but these are extremely slow and have not yet been tested. We discourage these methods to be used in Matlab at this stage (unless you are doing it for debugging purposes)

###
C++ 
###
- IVIM (BOBYQA) and SCIM methods are available in C++ form and will work on older 1.5T DWI data 
- Both C++ libraries however have not performed well on the new 3T scanner. This is being debugged at this stage.
- SPIM method is not available in C++ yet, however we are considering to implement this in python / julia (instead of C++) possibly at a later date.

###
Deep learning methods - 1D FCN and 2D CNN
###

1D FCN and 2D CNN require that a GPU is available on the machine where you are running the processing. 

NOTES ON 1D FCN: 
    - The number of b-values needs to be equal to the number of b-values that the network was trained with. If not - the network needs to be retrained. See further notes below. 
    - If the images to be processed have significant 'noise' in them, the network may need to be retrained with higher noise. 
    - A newer 1D FCN network exists (V2) which has not yet been implemented yet. This work is tbc. 



###
DIPY 
###
- DIPY implementation is based on Jaume Coll Font's code (ex CRL member). Newer DIPY implementation may be available at this stage (see their github for updates). 
- DIPY yields 'worse' results than CRL's IVIM (BOBYQA) voxelwise methods, as this is not a segmented fit.






##############################################################################
IGNORE: Serge's notes 
##############################################################################

7. [not used] run_dipy.py 
8. run_bobyqa.py or run_bobyqa_7bvalues.py and/or run_bobyqa_SCIM.py or run_bobyqa_SCIM_7bvalues.py
9. [not used] Generate 7 bvalue signals from parameter maps (add random noise to the signal...noise should be the same as the background in the b0 image in the original dataset) 
10. run_barbieri.py
11. run_roar.sh
12. visualize-result.sh
13. get-stats.py




