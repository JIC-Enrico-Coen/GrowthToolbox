function timedFprintf( varargin )
    if nargin==0
        return;
    end
    if isnumeric( varargin{1} )
        fid = varargin{1};
        varargin(1) = [];
    else
        fid = 1;
    end
    if ~isempty( varargin ) && isnumeric( varargin{1} )
        offset = varargin{1};
        varargin(1) = [];
    else
        offset = 2;
    end
    
    st = dbstack();
    if length(st) >= offset
        fprintf( fid, '%s %s(%d): ', datestring(true), st(offset).name, st(offset).line );
    else
        fprintf( fid, '%s: ', datestring(true) );
    end
    
    if isempty( varargin )
        fprintf( fid, 'Unspecified message.\n' );
    else
        fprintf( fid, varargin{:} );
    end
end
