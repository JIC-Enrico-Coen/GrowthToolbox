function [rev,date] = GFtboxRevision()
%[rev,date] = GFtboxRevision()
%   Determine the revision number and date of the GFtbox code, by looking
%   in GFtbox_version.txt in the Growth Toolbox directory.

    rev = 0;
    date = '';
    revisionFile = fullfile( GFtboxDir(), 'GFtbox_version.txt' );
    haveRevFile = exist( revisionFile, 'file' );
    if ~haveRevFile
        return;
    end
    % Read version number.
    try
        fid = fopen( revisionFile, 'r' );
        vs = fgetl( fid );
        filedate = fgetl( fid );
        fclose( fid );
    catch e %#ok<NASGU>
        return;
    end
    filerev = sscanf( vs, '%d' );
    if isempty( filerev )
        return;
    end
    date = filedate;
    if rev < filerev
        rev = filerev;
    end
end
