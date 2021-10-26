function time_cgs(m,n)
    if nargin < 2
        fprintf( 1, '%s: two integer arguments required.\n', mfilename() );
        return;
    end
    try
        A = rand(m,n);
        A1 = A;
        A1(1,1) = A(1,1);
        X = rand(n,1);
        B = A*X;
        B1 = B;
        B1(1,1) = B(1,1);
    catch e
        fprintf( 1, '%s: Out of memory.\n    %s\n', mfilename(), e.message );
        return;
    end

    tol = 0.0001;
    maxit = 5000;
    maxtime = 0;
    s = cputime;
    starttime = tic;
    [C,flag,relres,iter,resvec] = mycgs(A,B,tol,maxit,maxtime);
    wallClockTime = toc(starttime);
    computeTime = cputime - s;
    residual = A1*C - B1;
    aveAbsErr = sum(abs(residual))/length(residual);
    rmsErr = norm(residual)/sqrt(length(residual));
    fprintf( 1, 'Av abs err %.3g, rms err %.3g, wall time %.3f comp time %.3f\n', ...
        aveAbsErr, rmsErr, ...
        wallClockTime, computeTime );
end
