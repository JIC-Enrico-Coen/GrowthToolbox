function complain2( varargin )
%complain2( severity, msg, arg1, arg2, ... )
%   If SEVERITY is 0, this prints a time-stamped message prefixed with the
%   formatted arguments. If 1, it calls warning(), and if 2, calls error().
%
%   If SEVERITY is omitted (i.e. the first argument is non-numeric) it
%   defaults to 0.
%
%   See also: warning, error

    if nargin==0
        severity = 0;
        args = {};
    elseif isnumeric(varargin{1})
        severity = varargin{1};
        args = varargin(2:end);
    else
        severity = 0;
        args = varargin;
    end
    if isempty( args )
        args = { 'Unspecified problem.\n' };
    end
    switch severity
        case 0
            timedFprintf( 1, 3, args{:} );
            fwrite( 1, newline );
        case 1
            warning( args{:} );
        otherwise
            error( args{:} );
    end
end
