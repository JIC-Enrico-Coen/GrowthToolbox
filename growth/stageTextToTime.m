function [t,ok] = stageTextToTime( s )
%t = stageTextToTime( s )
%   Convert a stage suffix of the form 0123d456 to a number 123.456.
%   s may be a cell array, in which case t will be an array of floats.
%
%   See also: stageTimeToText.

    if iscell(s)
        ok = true;
        t = zeros(1,length(s));
        for i=1:length(s)
            [t(i),ok1] = oneStageTextToTime( s{i} );
            ok = ok && ok1; 
        end
    else
        [t,ok] = oneStageTextToTime(s);
    end
end

function [t,ok] = oneStageTextToTime( s )
    s = regexprep( s, '[dD]', '.' );
    [t,ok] = sscanf( s, '%f', 1 );
end
