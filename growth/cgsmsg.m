function cgsmsg( cgflag,cgrelres,cgiter,cgmaxiter )
    switch cgflag
        case 0
            fprintf( 1, 'CGS succeeded: converged to tolerance %g after %d of %d iterations.\n', cgrelres, cgiter, cgmaxiter );
        case 1
            fprintf( 1, 'CGS error %d: failed to converge to tolerance %g after %d of %d iterations.\n', cgflag, cgrelres, cgiter,cgmaxiter );
        case 2
            fprintf( 1, 'CGS error %d: preconditioner was ill-conditioned.\n', cgflag );
        case 3
            fprintf( 1, 'CGS error %d: stagnated after %d of %d iterations.\n', cgflag, cgiter, cgmaxiter );
        case 4
            fprintf( 1, 'CGS error %d: failed due to over/underflow after %d of %d iterations.\n', cgflag, cgiter, cgmaxiter );
        case 8
            fprintf( 1, 'CGS error %d: user requested stop after %d of %d iterations.\n', cgflag, cgiter, cgmaxiter );
        case 20
            fprintf( 1, 'CGS error %d: failed due to running out of time after %d of %d iterations.\n', cgflag, cgiter, cgmaxiter );
        case 21
            fprintf( 1, 'CGS error %d: failed due to excessive relative error %g after %d of %d iterations.\n', cgflag, cgrelres, cgiter, cgmaxiter );
        otherwise
            fprintf( 1, 'CGS error %d: failed after %d of %d iterations for miscellaneous reason.\n', cgflag, cgiter, cgmaxiter, cgflag );
    end
end


