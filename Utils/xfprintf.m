function count = xfprintf( varargin )
%xfprintf( ... )
%count = xfprintf( ... )
%   An extensible replacement for fprintf.  This is called in exactly the
%   same way as fprintf.  See sprintf forhow to define custom formats.

    [s,errmsg] = xsprintf( varargin{:} )
    if ~isempty(s)
        fwrite( fid, s );
    end
end

function c = unescape( c )
    switch c
        case 'n'
            c = char(10);
        case 'r'
            c = char(13);
        case 't'
            c = char(8);
    end
end

