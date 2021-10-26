function m = restoreManifoldSurface( m )
    go_on = true;
    iters = 0;
    while go_on
        [badElementMap,badEdgeMap] = checkManifoldSurface( m );
        if any(badElementMap)
            iters = iters+1;
            fprintf( 1, '%s iteration %d: %d non-manifold surface edges, deleting %d more elements.\n', ...
                mfilename(), iters, sum(badEdgeMap), sum(badElementMap) );
            m = deleteFEs( m, badElementMap );
        else
            go_on = false;
        end
    end
end
