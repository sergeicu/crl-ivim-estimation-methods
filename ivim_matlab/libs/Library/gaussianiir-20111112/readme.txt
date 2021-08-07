Fast Gaussian Convolution with Recursive Filtering

Pascal Getreuer, 2011


== Overview ==

This source code implements approximate Gaussian convolution in 1D, 2D, and 3D
using the efficient recursive filtering algorithm of Alvarez and Mazorra,

  Alvarez, Mazorra, "Signal and Image Restoration using Shock Filters and
  Anisotropic Diffusion," SIAM J. on Numerical Analysis, vol. 31, no. 2, 
  pp. 590-605, 1994.

The code is implemented in ANSI C for use in C and C++ programs, and MEX 
wrappers are included for use in MATLAB.  In case MEX is unavailable, (slower)
MATLAB M-code implementations are also included.

Gaussian convolution is attractive because it is rotationally invariant, 
satisfies a semi-group property, and it does not create new extrema or enhance
existing extrema.  Furthermore, the Gaussian decays rapidly in both space and 
frequency.  Thus Gaussian convolution is very popular in signal and image 
processing.  

The algorithm of Alvarez and Mazorra provides an efficient approximation of 
Gaussian convolution.  It uses a cascade of first order recursive filters, 
also called infinite impulse response or IIR filters, to simulate time steps
of the heat equation.  The speed vs. accuracy of the approximation is 
controlled by selecting the number of time steps.  

Useful aspects of this algorithm are

  * computational complexity is independent of the Gaussian standard deviation
  * the computation is in-place, and memory overhead is small and fixed
  * converges to exact solution in the limit number of time steps -> infinity

Caveats:

  * the method is approximate: it is not exactly invariant to rotations or 
    axis reflections (but accuracy can be improved by increasing the number of
    time steps)
  * this method is less useful for small sigma, where convolution with a 
    truncated Gaussian (FIR approximation) is more accurate/efficient
  * for high accuracy, consider instead Fourier-based Gaussian convolution 


== License ==

Files gaussianiir1d.c, gaussianiir2d.c, and gaussianiir3d.c, and the files of 
the same name but with extension .h and .m may be used with either the GPLv3 or 
simplified BSD license.

You can redistribute it and/or modify it under, at your option, the terms of 
the GNU General Public License as published by the Free Software Foundation, 
either version 3 of the License, or (at your option) any later version, or the
terms of the simplified BSD license.

You should have received a copy of these licenses along with this code.  If 
not, see <http://www.gnu.org/licenses/> and 
<http://www.opensource.org/licenses/bsd-license.html>.


== Demo ==

Included is a simple program "blurdemo" to apply the 2D Gaussian convolution
to color images.

Usage: blurdemo [options] <input file> <output file>

BMP images are supported, and optionally blurdemo can be compiled to use 
libjpeg, libpng, and libtiff to support JPEG, PNG, and TIFF images.

Options:
    -s <number>  sigma, the standard devation of the Gaussian in pixels
    -n <integer> number of timesteps (default 3)

Example:
    blurdemo -s 10 input.bmp blurred.bmp

The blurdemo program can be compiled with GCC using makefile.gcc as

    make -f makefile.gcc

or with MSVC using makefile.vc by opening a Visual Studio Command Prompt 
(under Start Menu > Microsoft Visual Studio > Visual Studio Tools) and 
entering

    nmake -f makefile.vc all


== Usage in C/C++ ==

The convolution itself is in gaussianiir1d.c, gaussianiir2d.c, and 
gaussianiir3d.c, implementing respectively 1D, 2D, and 3D.  There is no 
dependency among these files, so you may select the one that matches the
dimension of your application and ignore the other two.

The calling syntax of the convolution functions are 

        void gaussianiir1d(float *data, long length, float sigma, int numsteps);

        void gaussianiir2d(float *image, long width, long height, 
                float sigma, int numsteps);

        void gaussianiir3d(float *volume, long width, long height, long depth,
                float sigma, int numsteps);

In all three cases, the first argument is the input data, a contiguous array 
which is modified in-place and is the convolution output upon return.  
Boundaries are handled with half-sample symmetric extension.  The standard 
deviation is specified by sigma and the number of timesteps is specified by 
numsteps.  Using a larger value of numsteps increases the Gaussian 
approximation accuracy at the cost of increased computation time.  The run 
time is linear in numsteps and independent of sigma.  A reasonable default 
value for numsteps is 4.

In gaussianiir1d, data is expected to be a contiguous array of size length. 

In gaussianiir2d, image is expected to be in row-major order,
    image[x + width*y] = value at (x,y).

In gaussianiir3d, volume is expected to be ordered such that 
    volume[x + width*(y + height*z)] = value at (x,y,z).


== Usage in MATLAB ==

MATLAB MEX wrappers are included in gaussianiir1d.c, gaussianiir2d.c, and 
gaussianiir3d.c so that they can be compiled as fast MEX functions, usable 
from MATLAB.  To compile the MEX functions, enter

    >> mex gaussianiir1d.c
    >> mex gaussianiir2d.c
    >> mex gaussianiir3d.c

on the MATLAB console.  This should compile the MEX functions gaussianiir1d,
gaussianiir2d, and gaussianiir3d.

Alternatively, native M-code implementations of gaussianiir1d, gaussianiir2d,
and gaussianiir3d are included, but beware that they are significantly slower 
than the MEX versions.  To determine whether you are using the MEX version or
the M-code version, use MATLAB's "which" command:

    >> which gaussianiir1d
    /home/pascal/projects/gaussianiir/gaussianiir1d.mexa64

If the output ends in .m, you are using the M-code version.  Otherwise, you 
are using the compiled MEX function (the exact extension depends on platform, 
e.g., .mexw32 for 32-bit Windows).

The usage of gaussianiir1d is

    y = gaussianiir1d(x, sigma)

where x is the input array and sigma specifies the Gaussian standard 
deviation.  Optionally, the number of time steps can be specified as the third
argument,

    y = gaussianiir1d(x, sigma, numsteps)

If x is a matrix or multidimensional array, the convolution is performed 
independently on each column as if you had done 

    for j = 1:size(x,2)
        y(:,j) = gaussianiir1d(x(:,j), sigma, numsteps)
    end

The functions gaussianiir2d and gaussianiir3d are used in the same way, except 
that gaussianiir2d performs 2D convolution along the first two dimensions of x
and gaussianiir3d performs 3D convolution along the first three dimensions.

