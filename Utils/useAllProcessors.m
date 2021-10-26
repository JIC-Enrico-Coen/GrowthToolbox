function useAllProcessors( msg )
%useAllProcessors( msg )
%   Attempt to make use of all available processors.  This code is
%   Windows-specific and invokes deprecated Matlab procedures, and should
%   probably not be used.  It will not actually throw an error though.

    envNumProcessors = getenv('NUMBER_OF_PROCESSORS');
    if isempty( envNumProcessors )
        return;
    end
    [numProcessors,numints] = sscanf( envNumProcessors, '%d' );
    numDesiredThreads = numProcessors;
    if numints ~= 1
        fprintf( 1, ...
            '%s could not determine number of processors. Running in a single thread.\n', ...
            msg );
    elseif numProcessors <= 1
        fprintf( 1, '%s found a single processor: running in a single thread.\n', ...
            msg );
    elseif exist('setNumberOfComputationalThreads','file')==2
        setNumberOfComputationalThreads(numDesiredThreads);
        fprintf( 1, '%s using %d threads.\n', msg, numDesiredThreads );
    elseif exist('maxNumCompThreads','file')==2
        v = version('-release');
        if strmatch('201',v)
            fprintf( 1, '%s found %d processors; cannot set number of threads in MATLAB %s.\n', ...
                msg, numProcessors, v );
        else
            maxNumCompThreads(numDesiredThreads);
            fprintf( 1, '%s is using %d threads.\n', msg, numDesiredThreads );
        end
    else
        fprintf( 1, '%s found %d processors; number of threads not known.\n', ...
            msg, numProcessors );
    end
end
