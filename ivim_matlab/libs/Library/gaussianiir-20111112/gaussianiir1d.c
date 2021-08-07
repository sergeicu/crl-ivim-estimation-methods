/**
 * \file gaussianiir1d.c
 * \brief Fast 1D Gaussian convolution IIR approximation
 * \author Pascal Getreuer <getreuer@gmail.com>
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


/**
 * \brief Fast 1D Gaussian convolution IIR approximation
 * \param data the data to be convolved, modified in-place
 * \param length number of elements
 * \param sigma the standard deviation of the Gaussian in pixels
 * \param numsteps number of timesteps, more steps implies better accuracy
 *
 * Implements the fast Gaussian convolution algorithm of Alvarez and Mazorra,
 * where the Gaussian is approximated by a cascade of first-order infinite 
 * impulsive response (IIR) filters.  Boundaries are handled with half-sample
 * symmetric extension.
 * 
 * Gaussian convolution is approached as approximating the heat equation and 
 * each timestep is performed with an efficient recursive computation.  Using
 * more steps yields a more accurate approximation of the Gaussian.  A 
 * reasonable default value for \c numsteps is 4.
 *
 * Reference:
 * Alvarez, Mazorra, "Signal and Image Restoration using Shock Filters and
 * Anisotropic Diffusion," SIAM J. on Numerical Analysis, vol. 31, no. 2, 
 * pp. 590-605, 1994.
 */
void gaussianiir1d(float *data, long length, float sigma, int numsteps)
{
    double lambda, dnu;
    float nu, boundaryscale, postscale;
    long i;
    int step;
    
    if(!data || length < 1 || sigma <= 0 || numsteps < 0)
        return;
    
    lambda = (sigma*sigma)/(2.0*numsteps);
    dnu = (1.0 + 2.0*lambda - sqrt(1.0 + 4.0*lambda))/(2.0*lambda);
    nu = (float)dnu;
    boundaryscale = (float)(1.0/(1.0 - dnu));
    postscale = (float)(pow(dnu/lambda,numsteps));
    
    for(step = 0; step < numsteps; step++)
    {
        data[0] *= boundaryscale;
        
        /* Filter rightwards (causal) */
        for(i = 1; i < length; i++)
            data[i] += nu * data[i - 1];
        
        data[i = length - 1] *= boundaryscale;
        
        /* Filter leftwards (anti-causal) */
        for(; i > 0; i--)
            data[i - 1] += nu*data[i];
    }
    
    for(i = 0; i < length; i++)
        data[i] *= postscale;
    
    return;
}


#ifdef MATLAB_MEX_FILE  /* Only used if compiling as a MATLAB MEX function */
#include "mex.h"

#define DATA_IN         prhs[0]
#define SIGMA_IN        prhs[1]
#define NUMSTEPS_IN     prhs[2]
#define DATA_OUT        plhs[0]

void mexFunction(int nlhs, mxArray **plhs, int nrhs, const mxArray **prhs)
{ 
    float *data;
    float sigma;
    long length, j, J; 
    int numsteps;
    
    if(nrhs < 2)
        mexErrMsgTxt("Two input arguments required."); 
    else if(nlhs > 1)
        mexErrMsgTxt("Too many output arguments.");    
    if(mxIsSingle(DATA_IN))
        DATA_OUT = mxDuplicateArray(DATA_IN);
    else if(mexCallMATLAB(1, &DATA_OUT, 1, (mxArray **)&DATA_IN, "single"))
        mexErrMsgTxt("First argument must be a numeric array.");
    if(!mxIsNumeric(SIGMA_IN) || mxGetNumberOfElements(SIGMA_IN) != 1
        || (sigma = (float)mxGetScalar(SIGMA_IN)) <= 0)
        mexErrMsgTxt("Second argument must be a positive scalar.");    
    if(nrhs < 3)
        numsteps = 4;
    else if(!mxIsNumeric(NUMSTEPS_IN) 
        || mxGetNumberOfElements(NUMSTEPS_IN) != 1
        || (numsteps = (int)mxGetScalar(NUMSTEPS_IN)) <= 0)
        mexErrMsgTxt("Third argument must be a positive scalar.");
    
    length = (mxGetM(DATA_IN) > 1) ? mxGetM(DATA_IN) : mxGetN(DATA_IN);
    J = mxGetNumberOfElements(DATA_IN) / length;
    
    for(j = 0, data = mxGetData(DATA_OUT); j < J; j++, data += length)
        gaussianiir1d(data, length, sigma, numsteps);
    
    if(mxIsComplex(DATA_IN))  /* If complex, convolve imaginary part too */
        for(j = 0, data = mxGetImagData(DATA_OUT); j < J; j++, data += length)
            gaussianiir1d(data, length, sigma, numsteps);
    
    return;
}
#endif /* MATLAB_MEX_FILE*/
