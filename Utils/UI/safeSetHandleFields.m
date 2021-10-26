function safeSetHandleFields( h, s, fns )
%safeSetHandleFields( h, s )
%   H is a graphics handle, S is a struct, and FNS is a set of fieldnames
%   (which defaults to the set of all fieldnames of S).
%   For every field that occurs in FNS, S, and H, this procedure sets that
%   field of H to its value in S.  All error conditions are
%   ignored and there is no return value.  Case is ignored, e.g. fontweight
%   and FontWeight will both be recognised as valid fields of a text item.

    if ~ishghandle(h)
        return;
    end
    if nargin < 3
        fns = fieldnames(s);
    end
    hs = get(h);
    
    sf = fieldnames(s);
    if nargin < 3
        sfmap = ismember( lower(sf), lower(fieldnames(hs)) );
    else
        sfmap = ismember( lower(sf), intersect( lower(fns), lower(fieldnames(hs)) ) );
    end
    s = rmfield( s, sf(~sfmap) );
    
    set( h, s );
end
