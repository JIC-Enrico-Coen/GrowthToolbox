function bb = boundingbox( m, extra, allowzero )
%bb = boundingbox( m, extra, allowzero )
%   Calculate the bounding box of the mesh m, in a form that can be passed
%   to axis().  If extra is specified, the box is expanded by this amount,
%   e.g. if extra = 0.1 then the box will be 10% larger than the exact
%   bounds of the mesh.  If allowzero is false (the default is true) then
%   the bounding box is forced to have non-zero size in each dimension, by
%   expanding each zero-size dimension to equal the largest nonzero size,
%   if any, otherwise by expanding it to size 2.

    if usesNewFEs(m)
        lo = min( m.FEnodes, [], 1 );
        hi = max( m.FEnodes, [], 1 );
    else
        lo = min( m.prismnodes, [], 1 );
        hi = max( m.prismnodes, [], 1 );
    end
    if hasNonemptySecondLayer( m ) && (m.plotdefaults.layeroffset > 0)
        offsets = (0.5+m.plotdefaults.layeroffset) ...
                    .* (m.prismnodes( 2:2:end, : ) - ...
                        m.prismnodes( 1:2:(end-1), : ));
        offsets = max( abs(offsets), [], 1 );
        lo = lo - offsets;
        hi = hi + offsets;
    end
    if (nargin < 2) || isempty(extra)
        bb = reshape( [ lo; hi ], 1, [] );
    else
        mid = (lo+hi)/2;
        bb = reshape( [ lo + extra*(lo-mid); hi + extra*(hi-mid) ], 1, [] );
    end
    
    if (nargin>=3) && ~allowzero
        % Eliminate zero ranges from the bounding box.
        ranges = bb(2:2:end) - bb(1:2:(end-1));
        zeroranges = find(ranges <= 0);
        maxrange = max(ranges);
        if maxrange <= 0
            maxrange = 2;
        end
        zerohi = zeroranges*2;
        zerolo = zerohi-1;
        bb(zerohi) = bb(zerohi) + maxrange/2;
        bb(zerolo) = bb(zerolo) - maxrange/2;
    end
end
