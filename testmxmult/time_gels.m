function time_gels(m,n)
    if nargin < 2
        fprintf( 1, '%s: two integer arguments required.\n', mfilename() );
        return;
    end
    try
        A = rand(m,n);
        X = rand(n,1);
        B = A*X;
    catch e
        fprintf( 1, '%s: Out of memory.\n    %s\n', mfilename(), e.message );
        return;
    end
    
  % try_cgs(A,B);
    try_f(single(A),single(B),@test_cudaSgels,'cudaSgels');
  % try_f(A,B,@test_cudaDgels,'test_cudaDgels');
    try_f(A,B,@test_gels,'dgelsy');
  % try_f(A,B,@test_gelss,'dgelss');
  % try_dgelsy(A,B);
end

function try_f(A,B,f,name)
    A1 = A;
    A1(1,1) = A(1,1);
    B1 = B;
    B1(1,1) = B(1,1);
    s = cputime;
    [C] = f( A, B );
    %  C[1] = timeTaken;
    %  C[2] = lwork;
    %  C[3] = rank;
    %  C[4] = info;
    computeTime = cputime - s;
    residual = A1*B - B1;
    aveAbsErr = sum(abs(residual))/length(residual);
    rmsErr = norm(residual)/sqrt(length(residual));
    fprintf( 1, '%s: av abs err %.3g, rms err %.3g, rank def %d/%d, wall time %.3f comp time %.3f\n', ...
        name, aveAbsErr, rmsErr, ...
        size(A,1) - int32(C(3)), size(A,1), ...
        C(1), computeTime );
end

function try_dgelsy(A,B)
    A1 = A;
    A1(1,1) = A(1,1);
    B1 = B;
    B1(1,1) = B(1,1);
    s = cputime;
    [C] = test_gels( A, B );
    computeTime = cputime - s;
    residual = A1*B - B1;
    aveAbsErr = sum(abs(residual))/length(residual);
    rmsErr = norm(residual)/sqrt(length(residual));
    fprintf( 1, 'dgelsy: av abs err %.3g, rms err %.3g, rank def %d/%d, wall time %.3f comp time %.3f\n', ...
        aveAbsErr, rmsErr, ...
        size(A,1) - int32(C(3)), size(A,1), ...
        C(1), computeTime );
end

function try_cgs(A,B)
    A1 = A;
    A1(1,1) = A(1,1);
    B1 = B;
    B1(1,1) = B(1,1);
    tol = 0.0001;
    maxit = 1000;
    maxtime = 0;
    s = cputime;
    starttime = tic;
    [C,flag,relres,iter,resvec] = mycgs(A,B,tol,maxit,maxtime);
    if flag ~= 0
        fprintf( 1, 'cgs error: ' );
        cgsmsg( flag,relres,iter,maxit );
    end
    wallClockTime = toc(starttime);
    computeTime = cputime - s;
    residual = A1*C - B1;
    aveAbsErr = sum(abs(residual))/length(residual);
    rmsErr = norm(residual)/sqrt(length(residual));
    fprintf( 1, 'cgs:    av abs err %.3g, rms err %.3g, wall time %.3f comp time %.3f\n', ...
        aveAbsErr, rmsErr, ...
        wallClockTime, computeTime );
end
