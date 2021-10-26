#undef MACOS
#define WIN64

#include <sys/timeb.h>

#include "mex.h"
#include "blas.h"

#include "lapack.h"

#ifdef WIN64
#include "C:/Program Files/CULA/include/cula.h"
#else
#include "cula.h"
#endif

// RK 2007-11-26 19:09

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
  float *A, *B, *C, *D, *E, one = 1.0, zero = 0.0;
  int arows,acols,bcols,lda,ldb;
  int info = 0;
  char *chn = "N";
  int iter;
  int numiters = 100;
  float timeTaken;
  int startTime, endTime;
  int *jpvt;
  float rcond = 0.0001;
  int rank = 0;
  int lwork = -1;
  float *work = NULL;
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
      C = (float *) mxGetPr(plhs[0]);
  }
  
  

  A = (float *) mxGetPr(prhs[0]);
  B = (float *) mxGetPr(prhs[1]);
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

    culaSgesv(
        acols,     // int    *n,
        bcols,     // int    *nrhs,
        A,          // float *a,
        lda,     // int    *lda,
        jpvt,
        B,          // float *b,
        ldb       // int    *ldb
    );

  endTime = mtime();
  timeTaken = (endTime-startTime)*0.001;
  if (nlhs == 1) {
      C[0] = timeTaken;
  }
  free(jpvt);
}
