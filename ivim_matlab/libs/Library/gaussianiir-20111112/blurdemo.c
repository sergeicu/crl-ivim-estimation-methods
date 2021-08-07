/**
 * @file blurdemo.c
 * @brief Fast 2D Gaussian Convolution with Recursive Filtering
 * @author Pascal Getreuer <getreuer@gmail.com>
 *
 * Copyright (c) 2011, Pascal Getreuer
 * All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under, at your option, the terms of the GNU General Public License as 
 * published by the Free Software Foundation, either version 3 of the 
 * License, or (at your option) any later version, or the terms of the 
 * simplified BSD license.
 *
 * You should have received a copy of these licenses along with this program.
 * If not, see <http://www.gnu.org/licenses/> and
 * <http://www.opensource.org/licenses/bsd-license.html>.
 */

#include <math.h>
#include <string.h>
#include <ctype.h>

#include "imageio.h"
#include "gaussianiir2d.h"


/** @brief struct of program parameters */
typedef struct
{
    /** @brief Input file */
    const char *InputFile;
    /** @brief Output file (blurred) */
    const char *OutputFile;    
    /** @brief Quality for saving JPEG images (0 to 100) */
    int JpegQuality;
        
    /** @brief sigma parameter of the Gaussian */
    float sigma;
    /** @brief Number of timesteps  */
    int numsteps;
} programparams;    
    

static int ParseParams(programparams *Param, int argc, char *argv[]);
    

/** @brief Print program usage help message */
void PrintHelpMessage()
{
    printf("Fast 2D Gaussian IIR blurring demo, P. Getreuer 2011\n\n");
    printf("Usage: blurdemo [options] <exact file> <distorted file>\n\n"
        "Only " READIMAGE_FORMATS_SUPPORTED " images are supported.\n\n");
    printf("Options:\n");
    printf("   -s <number>  sigma, the standard devation of the Gaussian in pixels\n");
    printf("   -n <integer> number of timesteps (default 3)\n");
#ifdef LIBJPEG_SUPPORT
    printf("   -q <number>  Quality for saving JPEG images (0 to 100)\n\n");
#endif    
    printf("Example:\n"
#ifdef LIBPNG_SUPPORT
        "   blurdemo -s 10 input.png blurred.png\n");
#else
        "   blurdemo -s 10 input.bmp blurred.bmp\n");
#endif
}   


int main(int argc, char *argv[])
{
    float *imagedata;
    int width, height;
    programparams Param;
    unsigned long start;
    int numpixels, channel, status = 1;    
    
    if(!ParseParams(&Param, argc, argv))
        return 0;
    
    if(!(imagedata = (float *)ReadImage(&width, &height, Param.InputFile, 
        IMAGEIO_FLOAT | IMAGEIO_RGB | IMAGEIO_PLANAR)))
        goto Catch;
    
    printf("Gaussian IIR blurring on %dx%d image, sigma=%g, numsteps=%d\n", 
           width, height, Param.sigma, Param.numsteps); 
    
    numpixels = width*height;
    start = Clock();
        
    for(channel = 0; channel < 3; channel++)
        gaussianiir2d(imagedata + channel*numpixels, width, height, 
            Param.sigma, Param.numsteps);
    
    printf("CPU time: %.3f\n", 0.001f*(Clock() - start));
        
    if(!WriteImage(imagedata, width, height, Param.OutputFile, 
        IMAGEIO_FLOAT | IMAGEIO_RGB | IMAGEIO_PLANAR, Param.JpegQuality))
        goto Catch;
    
    status = 0; /* Finished successfully */
Catch:
    Free(imagedata);
    return status;
}

static int ParseParams(programparams *Param, int argc, char *argv[])
{
    const char *DefaultOutput = (const char *)"out.bmp";
    char *OptionString;
    char OptionChar;
    int i;

    
    if(argc < 2)
    {
        PrintHelpMessage();
        return 0;
    }
    
    /* Set parameter defaults */
    Param->InputFile = NULL;
    Param->OutputFile = DefaultOutput;
    Param->sigma = 10.0f;    
    Param->numsteps = 3;
    Param->JpegQuality = 95;
        
    for(i = 1; i < argc;)
    {
        if(argv[i] && argv[i][0] == '-')
        {
            if((OptionChar = argv[i][1]) == 0)
            {
                ErrorMessage("Invalid parameter format.\n");
                return 0;
            }

            if(argv[i][2])
                OptionString = &argv[i][2];
            else if(++i < argc)
                OptionString = argv[i];
            else
            {
                ErrorMessage("Invalid parameter format.\n");
                return 0;
            }
            
            switch(OptionChar)
            {
            case 's':
                Param->sigma = atof(OptionString);
                
                if(Param->sigma < 0)
                {
                    ErrorMessage("sigma must be nonnegative.\n");
                    return 0;
                }
                break;            
            case 'n':
                Param->numsteps = atoi(OptionString);
                
                if(Param->numsteps <= 0)
                {
                    ErrorMessage("Number of steps must be positive.\n");
                    return 0;
                }
                break;
#ifdef LIBJPEG_SUPPORT
            case 'q':
                Param->JpegQuality = atoi(OptionString);

                if(Param->JpegQuality <= 0 || Param->JpegQuality > 100)
                {
                    ErrorMessage("JPEG quality must be between 0 and 100.\n");
                    return 0;
                }
                break;
#endif
            case '-':
                PrintHelpMessage();
                return 0;
            default:
                if(isprint(OptionChar))
                    ErrorMessage("Unknown option \"-%c\".\n", OptionChar);
                else
                    ErrorMessage("Unknown option.\n");

                return 0;
            }

            i++;
        }
        else
        {
            if(!Param->InputFile)
                Param->InputFile = argv[i];
            else
                Param->OutputFile = argv[i];

            i++;
        }
    }
    
    if(!Param->InputFile || !Param->OutputFile)
    {
        PrintHelpMessage();
        return 0;
    }
    
    return 1;
}
