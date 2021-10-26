function fid = openfilewrite( file, ext, msg )
%fid = openfilewrite( file, ext, msg )
%   If FILE is a string, open the file for writing and return the
%   file id.
%
%   If EXT is supplied force the filename to have that extension.
%
%   MSG is a string to be prefixed to any error messages written to the
%   console.
%
%   FID is -1 in case of any error, otherwise it is an open file
%   descriptor.

    if ~ischar(file)
        fid = -1;
        fprintf( 1, '%s: Invalid argument of type ''%s'', string expected.\n', msg, class(file) );
        return;
    end
    if (nargin >= 2) && ~isempty(ext)
        ext = ['.' ext];
        if (length(file) < length(ext)) || ~strcmp( file( (end-length(ext)+1):end ), ext )
            file = [file ext];
        end
    end
    fid = fopen( file, 'w' );
    if fid==-1
        fprintf( 1, '%s: Could not open file ''%s'' for writing.\n', msg, file );
    end
end
