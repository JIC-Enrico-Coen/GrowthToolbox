function result = isGFtboxProjectDir( pathname )
%result = isGFtboxProjectDir( pathname )
%   Returns TRUE or FALSE depending on whether PATHNAME is a path to a
%   GFtbox project directory.  The test is that the directory contain a
%   MAT-file whose basename is identical to the name of the directory.
%
%   PATHNAME may also be a cell array of names, and result will be a
%   boolean array of the same shape.

    if iscell( pathname )
        result = false(1,numel(pathname));
        for i=1:numel(pathname)
            result(i) = isGFtboxProjectDir( pathname{i} );
        end
        result = reshape( result, size(pathname) );
    else
        [~,dirbasename] = dirparts( pathname );
        projectfilename = fullfile( pathname, [dirbasename, '.mat'] );
        result = exist( projectfilename, 'file' ) == 2;
    end
end
