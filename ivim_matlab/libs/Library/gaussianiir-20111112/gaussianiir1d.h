/**
 * \file gaussianiir1d.h
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

#ifndef _GAUSSIANIIR1D_H_
#define _GAUSSIANIIR1D_H_

void gaussianiir1d(float *data, long length, float sigma, int numsteps);

#endif
