function makeDefaultThumbnail( m )
%makeDefaultThumbnail( m )
%   Make a default thumbnail for a mesh.
%   This only does something if m is part of a project and the project has
%   no thumbnail file already.

    if isempty(m)
        return;
    end
    
	if isempty(m.globalProps.projectdir)
        fprintf( 1, 'makeDefaultThumbnail: no project.\n' );
        return;
    end

    thumbfilename = fullfile( getModelDir(m), 'GPT_thumbnail.png' );
    if exist( thumbfilename, 'file' )
        fprintf( 1, 'makeDefaultThumbnail: thumbnail exists.\n' );
        return;
    end

    fprintf( 1, 'makeDefaultThumbnail: making thumbnail.\n' );
    leaf_snapshot( m, '', 'thumbnail', 1 );
end
