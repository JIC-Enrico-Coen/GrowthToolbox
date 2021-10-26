function grantednum = attemptCreation( maxnum, usednum, requestednum )
%grantednum = attemptCreation( maxnum, usednum, requestednum )
%   A resource is in limited supply: initially there was MAXNUM of it.
%   USEDNUM is the amount that has been used. The probability of acquiring
%   another unit of the resource is 1 - USEDNUM/MAXNUM.
%
%   We attempt to acquire REQUESTEDNUM of it. Return the number actually
%   granted.
%
%   MAXNUM can validly be Inf, in which case all the requests are granted.
%   USEDNUM must be finite. REQUESTEDNUM can be arbitrarily large,
%   including Inf, in which case all available resources will be granted.
%
%   Note that even if REQUESTEDNUM is no larger than maxnum - usednum, not
%   all of the requests may be granted. The model is that you reach
%   REQUESTEDNUM times into a box containing all the resources, and draw
%   one at random. If that one is already in use, the resource is not
%   granted. In either case, the resource is put back into the box before
%   the next drawing.

    initialnum = usednum;
    if isinf( requestednum )
        grantednum = max( 0, maxnum - usednum );
    else
        for i=1:requestednum
            curProb = 1 - usednum/maxnum;
            if curProb <= 0
                break;
            end
            created = rand() < curProb;
            if created
                usednum = usednum+1;
            end
        end
        grantednum = usednum - initialnum;
    end
end