function s = datestring( c, timeonly )
%s = datestring( c, timeonly )
%   Return the date and time as a string in a standard format.
%
%   C defaults to the current time as accessed by clock().
%
%   If TIMEONLY is true (the default is false) the day will be omitted.
%
%   Examples:
%
%       datestring
%           '2023/06/20 15:27:12'
%
%       datestring( false )
%           '15:27:12'
%
%   See also: clock

    if nargin < 1
        c = clock;
        timeonly = false;
    elseif numel(c)==1
        timeonly = logical(c);
        c = clock();
    elseif nargin < 2
        timeonly = false;
    end
    if timeonly
        s = sprintf( '%02d:%02d:%02d', round(c(4:6)) );
    else
        s = sprintf( '%d/%02d/%02d %02d:%02d:%02d', round(c) );
    end
    if nargout < 1
        fwrite( 1, s );
    end
end