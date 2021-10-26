function s = timestr( seconds, fmt )
%s = timestr( seconds, fmt )
%   Convert a number of seconds to a formatted string that may include
%   days, hours, minutes, seconds, and milliseconds.
%
%   In FMT, a string of 'D's is replaced by the number of days, padded if
%   necessary with leading zeros to match the number of 'D's.
%   Similarly, 'H' is for hours, 'M' for minutes', 'S' for seconds, and 'F'
%   for the fractional part (for which the number of 'F's is the required
%   number of decimal digits).
%
%   The default value of FMT is 'HH:MM:SS.FFF'.
%
%   For example:
%
%   timestr(12345.678) returns '03:25:45.677'.
%   timestr(12345.678,'MM:SS.FFFF') returns '205:45.6780'.
%   timestr(12345.678,'HH:SS.FF') returns '03:1545.68'.

    if nargin < 2
        fmt = 'HH:MM:SS.FFF';
    end
    [s,seconds] = testPart( fmt, 'D', 86400, seconds );
    [s,seconds] = testPart( s, 'H', 3600, seconds );
    [s,seconds] = testPart( s, 'M', 60, seconds );
    [s,seconds] = testPart( s, 'S', 1, seconds );
    s = testPart( s, 'F', 1, seconds );
end

function [fmt,seconds] = testPart( fmt, part, n, seconds )
    partpattern = [part '*'];
    [s,e] = regexp( fmt, partpattern, 'start', 'end' );
    found = ~isempty(s);
    if found
        if part ~= 'F'
            p = floor( seconds/n );
            seconds = seconds - n*p;
        end
        for i=length(s):-1:1
            len = e(i)-s(i)+1;
            if part=='F'
                p1 = round( (seconds-floor(seconds))*10^len );
            else
                p1 = p;
            end
            replacement = sprintf( '%0*d', len, p1 );
            fmt = replacesubstring( fmt, replacement, s(i), e(i) );
        end
    end
end

function str = replacesubstring( str, insert, s, e )
    str = [ str(1:(s-1)) insert str((e+1):end) ];
end
