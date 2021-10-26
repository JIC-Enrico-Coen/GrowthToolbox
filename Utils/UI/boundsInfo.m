function s = boundsInfo( bounds )
%s = boundsInfo( bounds )
%   Construct a string to indicate to the user the maximum, minimum, or
%   allowed range in a dialog requesting a number.

    if isinf( bounds(1) )
        if isinf( bounds(2) )
            s = '';
        else
            s = [' (max ' num2string(bounds(2)) ')' ];
        end
    elseif isinf( bounds(2) )
        s = [' (min ' num2string(bounds(1)) ')' ];
    else
        s = [' (range ' num2string(bounds(1)), ' to ' num2string(bounds(2)) ')' ];
    end
end

