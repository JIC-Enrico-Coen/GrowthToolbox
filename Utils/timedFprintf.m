function timedFprintf( varargin )
%timedFprintf( ... )
%   Acts as fprintf, but prefixes the output with a timestamp, the name of
%   the .m file it was invoked from, the name of the function within that
%   file (if different), and the line number.

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
    
    st = dbstack('-completenames');
    if length(st) >= offset
        [~,filename] = fileparts( st(offset).file );
        funcname = st(offset).name;
        if strcmp(filename,funcname)
            fprintf( fid, '%s %s(%d): ', datestring(true), funcname, st(offset).line );
        else
            fprintf( fid, '%s %s>%s(%d): ', datestring(true), filename, funcname, st(offset).line );
        end
    else
        fprintf( fid, '%s: ', datestring(true) );
    end
    
    if isempty( varargin )
        fprintf( fid, 'Unspecified message.\n' );
    else
        fprintf( fid, varargin{:} );
    end
end
