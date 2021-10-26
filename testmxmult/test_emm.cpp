#undef MACOS
#define WIN64

#include <sys/timeb.h>

#include "mex.h"
#include "blas.h"

#include "lapack.h"

// RK 2007-11-26 13:39
// It works, Gflops = 16.6251 for two 1000*1000 matrices, 100 times.

int mtime() {
   struct _timeb timebuffer;
   _ftime64_s( &timebuffer );
   fprintf( stderr, "time %d msecs %d\n", timebuffer.time, timebuffer.millitm );
    return( timebuffer.time*1000 + timebuffer.millitm );
}

void foo() {
    dgelsy( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );
/*
 void dgelsy(
    int    *m,
    int    *n,
    int    *nrhs,
    double *a,
    int    *lda,
    double *b,
    int    *ldb,
    int    *jpvt,
    double *rcond,
    int    *rank,
    double *work,
    int    *lwork,
    int    *info
);
*/
}


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  double *A, *B, *C, *D, one = 1.0, zero = 0.0;
  int m,n,p; 
  char *chn = "N";
  int iter;
  int numiters = 100;
	  double timeTaken;
	  double desiredGigaOperations = 10;
	  double gigaOperationsPerIter;
	  double gigaOperations;
	  double gigaFlops;
	  int startTime, endTime;

  A = mxGetPr(prhs[0]);
  B = mxGetPr(prhs[1]);
  m = mxGetM(prhs[0]);
  p = mxGetN(prhs[0]);
  n = mxGetN(prhs[1]);

  if (p != mxGetM(prhs[1])) {mexErrMsgTxt
    ("Inner dimensions of matrix multiply do not match");
  }

  plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
  D = mxGetPr(plhs[1]);
  plhs[0] = mxCreateDoubleMatrix(m, n, mxREAL);
  C = mxGetPr(plhs[0]);
  if (C==0) {
      D[0,0] = -1;
      return;
  }

  gigaOperationsPerIter = ((double)m)*((double)p)*((double)n)/1000000000.0;
  numiters = desiredGigaOperations/gigaOperationsPerIter;
  if (numiters < 1) { numiters = 1; }
  startTime = mtime();
  /* Pass all arguments to Fortran by reference */
  for (iter=0; iter < numiters; ++iter) {
      dgemm(chn, chn, &m, &n, &p, &one, A, &m, B, &p, &zero, C, &m);
  }
  endTime = mtime();
  timeTaken = (endTime-startTime)*0.001;
  if (timeTaken==0) {
      gigaOperations = 0;
      gigaFlops = 0;
  } else {
      gigaOperations = gigaOperationsPerIter*numiters;
      gigaFlops = gigaOperations/timeTaken;
  }
  D[0,0] = gigaFlops;
  
  if (0) { foo(); }
}
