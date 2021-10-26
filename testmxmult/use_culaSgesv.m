function [status,U1] = use_culaSgesv( K, U )
    K1 = single(K);
    K1(1,1) = K(1,1);
    U1 = single(U);
    U1(1,1) = U(1,1);
    s = cputime;
    [C] = test_cudaSgels( K1, U1 );
    computeTime = cputime - s;
    residual = K*U1 - U;
    aveAbsErr = sum(abs(residual))/length(residual);
    rmsErr = norm(residual)/sqrt(length(residual));
    fprintf( 1, '%s: err code %d, av abs err %.3g, rms err %.3g, wall time %.3f comp time %.3f\n', ...
        mfilename(), C(2), aveAbsErr, rmsErr, ...
        C(1), computeTime );
    status = C(2);
end
