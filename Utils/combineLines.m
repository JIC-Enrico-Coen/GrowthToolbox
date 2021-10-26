function [xvals, yvals, zvals] = combineLines( xvals, yvals, zvals )
    nans = nan( 1, size(xvals,2) );
    xvals = reshape( [ xvals; nans ], [], 1 );
    yvals = reshape( [ yvals; nans ], [], 1 );
    zvals = reshape( [ zvals; nans ], [], 1 );
end
