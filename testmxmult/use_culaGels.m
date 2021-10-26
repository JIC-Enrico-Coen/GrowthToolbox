function [C,B1] = use_culaSgesv( K, UC )
    A1 = single(A);
    A1(1,1) = A(1,1);
    B1 = single(B);
    B1(1,1) = B(1,1);
    s = cputime;
    [C] = test_cudaSgels( A1, B1 );
    computeTime = cputime - s;
    residual = A*B1 - B;
    aveAbsErr = sum(abs(residual))/length(residual);
    rmsErr = norm(residual)/sqrt(length(residual));
    fprintf( 1, '%s: av abs err %.3g, rms err %.3g, wall time %.3f comp time %.3f\n', ...
        name, aveAbsErr, rmsErr, ...
        C(1), computeTime );
end
