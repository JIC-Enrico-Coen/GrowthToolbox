
#include <sys/timeb.h>

#include "mex.h"
#include "blas.h"

#include "lapack.h"
#include "cula.h"

// RK 2007-11-26 19:09

#define MACOS

int mtime() {
#ifdef MACOS
   struct timeb timebuffer;
   ftime( &timebuffer );
#else
   struct _timeb timebuffer;  // Doesn't work on Mac
   _ftime64_s( &timebuffer );  // Doesn't work on Mac
#endif
   fprintf( stderr, "time %d msecs %d\n", timebuffer.time, timebuffer.millitm );
    return( timebuffer.time*1000 + timebuffer.millitm );
}



void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  double *A, *B, *C, *D, *E, one = 1.0, zero = 0.0;
  int arows,acols,bcols,lda,ldb;
  int info = 0;
  char *chn = "N";
  int iter;
  int numiters = 100;
  double timeTaken;
  int startTime, endTime;
  int *jpvt;
  double rcond = 0.0001;
  int rank = 0;
  int outputSize = 4;
  
  if (nrhs != 2) {
      mexErrMsgTxt( "test_gels requires 2 arguments.\n" );
      return;
  }
  if (nlhs > 1) {
      mexErrMsgTxt( "test_gels produces at most 1 result.\n" );
      return;
  }
  if (nlhs == 1) {
      plhs[0] = mxCreateDoubleMatrix(1, outputSize, mxREAL);
      C = mxGetPr(plhs[0]);
  }
  
  

  A = mxGetPr(prhs[0]);
  B = mxGetPr(prhs[1]);
  arows = mxGetM(prhs[0]);
  acols = mxGetN(prhs[0]);
  bcols = mxGetN(prhs[1]);

  if (acols != mxGetM(prhs[1])) {mexErrMsgTxt
    ("Inner dimensions of matrix multiply do not match");
  }

  startTime = mtime();
  lda = arows;
  ldb = arows;  if (ldb < acols) { ldb = acols; }
  jpvt = (int *) calloc( acols, sizeof(int) );

  mexPrintf("culaDgesv( %d, %d, %lx, %d, %x, %lx, %d )\n",
        acols,     // int    *n,
        bcols,     // int    *nrhs,
        A,          // double *a,
        lda,     // int    *lda,
        jpvt,
        B,          // double *b,
        ldb       // int    *ldb
    );

//  culaStatus culaDgesv(int n, int nrhs, culaDouble* a, int lda, culaInt* ipiv, culaDouble* b, int ldb);
    culaStatus result = culaInitialize();
    mexPrintf( "culaInitialize status = %d\n", result );
//  return;
    result = culaDgesv(
        acols,     // int    *n,
        bcols,     // int    *nrhs,
        A,          // double *a,
        lda,     // int    *lda,
        jpvt,
        B,          // double *b,
        ldb       // int    *ldb
    );
    mexPrintf( "culaSgesv status = %d\n", result );
    culaShutdown();

  endTime = mtime();
  timeTaken = (endTime-startTime)*0.001;
  if (nlhs == 1) {
      C[0] = timeTaken;
      C[1] = result;
  }
  free(jpvt);
}
