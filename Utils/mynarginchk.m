function mynarginchk( low, high )
%mynarginchk( mn, mx )
%   This calls narginchk if it exists (it was introduced in version 2011b),
%   otherwise emulates it with nargchk (which in 2015a is deprecated and
%   will be withdrawn in some future version).

    if exist( 'narginchk', 'builtin' )
        narginchk( low, high );
    else
        error( nargchk(low, high, nargin(), 'struct') );
    end
end
