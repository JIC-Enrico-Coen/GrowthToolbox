function [times,fromold,fromnew] = addStages( oldtimes, newtimes, stagerounding )
%[times,fromold,fromnew] = addStages( oldtimes, newtimes )
%   Combine the lists of times, striking out duplicates and
%   putting them into sorted order.  fromold and fromnew are bitmaps of the
%   result, showing which elements came from which list.
%   oldtimes and newtimes do not have to already be sorted, and they may
%   contain duplicates.

    if nargin < 3
        stagerounding = 6;
    end
    
    oldtimes = myround( oldtimes, stagerounding );
    newtimes = myround( newtimes, stagerounding );

    times = unique( [oldtimes, newtimes] );

    if nargout >= 2
        [x,i] = setdiff( times, oldtimes );
        fromold = true( size(times) );
        fromold(i) = false;
    end

    if nargout >= 3
        [x,i] = setdiff( times, newtimes );
        fromnew = true( size(times) );
        fromnew(i) = false;
    end
end
