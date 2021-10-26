/*
 *check xp environmental variables for BLAS_VERSION and OMP_NUM_THREADS
 *if necessary point to the latest version from INTEL
 *
 */

// testblas.cpp : Defines the entry point for the DLL application.
//
//mex testblas.cpp 'C:\Program Files\MATLAB\R2007a\extern\lib\win32\microsoft\libmwlapack.lib'

// for help on changing the blas library used by matlab
// http://www.mathworks.com/support/solutions/data/1-JDIO3.html?solution=1-JDIO3
// better
//http://www.mathworks.com/support/solutions/data/1-18QUC.html?solution=1-18QUC
/*
The way MATLAB works on selecting which BLAS to use is to first check the BLAS_VERSION environment variable. If the variable is defined, MATLAB will use the specified file. If it is not defined, MATLAB will use the information in $MATLABROOT\bin\$(ARCH)\blas.spec (where $MATLABROOT is the MATLAB root directory on your machine, as returned by typing

matlabroot

at the MATLAB Command Prompt) to determine which version of our pre-shipped BLAS to load.

Hence if there is no BLAS_VERSION environmental variable on your system you may do the following: Edit blas.spec yourself to make your processor call any of the other MathWorks supplied BLAS in the bin\$(ARCH) directory.

To change the BLAS using the environmental variables, you need to set them. The method for doing this is different for each operating system. 

On Windows XP, you can set the environment variables using the following steps:

1. Right click on “My Computer” and select “Properties”.
2. Click on the “Advanced” tab.
3. Click on the “Environment Variables” button.
4. Set the variables under “System variables”.


http://www.mathworks.com/support/solutions/data/1-34HE9M.html?solution=1-34HE9M
 
 */


#include "stdafx.h"

#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, mxArray 
*prhs[])
{
  double *A, *B, *C, one = 1.0, zero = 0.0;
  int m,n,p; 
  char *chn = "N"; // i.e. do not transpose either matrix

  A = mxGetPr(prhs[0]);
  B = mxGetPr(prhs[1]);
  m = (int)mxGetM(prhs[0]);
  p = (int)mxGetN(prhs[0]);
  n = (int)mxGetN(prhs[1]);

  if (p != mxGetM(prhs[1])) {
    mexErrMsgTxt("Inner dimensions of matrix multiply do not match");
  }

  plhs[0] = mxCreateDoubleMatrix(m, n, mxREAL);
  C = mxGetPr(plhs[0]);

  /* Pass all arguments to Fortran by reference */
  dgemm (chn, chn, &m, &n, &p, &one, A, &m, B, &p, &zero, C, &m);
  /* actually dgemm is a BLAS level 3 routine not LAPACK */
  /* 
   call dgemm(transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc)
   */
  /* ACTUALLY, WE SHOULD NOT USE THE C LIBRARY, MATLAB INDEXES FROM 1 LIKE FORTRAN  

   dgemv     (chn,   &m,&n, &one,  A, &m,  B, &one,&zero, C, &one);
   
   call dgemv( trans, m, n, alpha, a, lda, x, incx, beta, y, incy )
   incx INTEGER. Specifies the increment for the elements of x. The value of incx must not be zero.
   */
  
}


