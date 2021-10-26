function ok = checkallints( msg, list, max )
%ok = checkallints( msg, list, max )
%   Check that list is 1:max.  Complain if not.
%   List is expected to be a list of integers resulting from a call of
%   unique(), i.e. sorted with no repetitions.  This implies that it is
%   necessary and sufficient that it have the right length, and if nonempty,
%   begins with 1 and ends with max.

    ok = false;
    ll = length(list);
    if ll < max
        fprintf( 1, '%s: only %d items found but %d expected.\n', msg, ll, max );
        return;
    end
    if ll > max
        fprintf( 1, '%s: %d items found but only %d expected.\n', msg, ll, max );
        return;
    end
    if max==0
        ok = true;
        return;
    end
    if list(1) ~= 1
        fprintf( 1, '%s: first item found is %d instead of 1.\n', msg, list(1) );
        return;
    end
    if (max > 1) && (list(ll) ~= max)
        fprintf( 1, '%s: last item found is %d instead of %d.\n', msg, list(ll), max );
        return;
    end
    ok = true;
end
