function ok = checkIndexingInto( indexingarray, indexedarray, zerobased, nonFiniteOk, nullsOk, msg )
    if nonFiniteOk
        indexes = indexingarray( isfinite(indexingarray) );
    else
        indexes = indexingarray(:);
    end
    if zerobased
        good = ((indexes>=0) & (indexes < size(indexedarray,1))) | (nullsOk & (indexes==-1));
    else
        good = (indexes>0) & (indexes <= size(indexedarray,1)) | (nullsOk & (indexes==0));
    end
    ok = all(good);
    if ~ok
        fprintf( 1, '%s: %d indexes out of range\n', msg, sum(~good) );
    end
end
