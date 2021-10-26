function time_emm(m,n,p)
    try
        A = rand(m,n);
        B = rand(n,p);
    catch e
        fprintf( 1, '%s: Out of memory.\n    %s\n', mfilename(), e.message );
    end
    s = cputime;
    starttime = tic;

    [C,D] = test_emm(A,B);
    
    wallClockTime = toc(starttime)
    computeTime = cputime - s
    D
end
