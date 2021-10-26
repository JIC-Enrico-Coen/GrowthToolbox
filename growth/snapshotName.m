function name = snapshotName( m, t, thumbnail )
%name = snapshotName( m )
%   Return the name of the snapshot file that would be created at the
%   current time.
%name = snapshotName( m, t )
%   Return the name of the snapshot file that would be created at time t.
%name = snapshotName( m, 'thumbnail' )
%   Return the name of the thumbnail file for m.
%name = snapshotName( m, t, thumbnail )
%   If THUMBNAIL is true, ignore T and return the name of the thumbnail
%   file. Otherwise return the name the snapshot file for time t.
%
%The file need not exist.

    if nargin < 2
        t = [];
    end
    if isempty(t)
        t = m.globalDynamicProps.currenttime;
    end
    if nargin < 3
        thumbnail = strcmp(t,'thumbnail');
    end

    if isempty(m.globalProps.modelname)
        snapshotname = 'snapshot';
    else
        snapshotname = m.globalProps.modelname;
    end
    if thumbnail
        name = 'GPT_thumbnail.png';
    else
        name = sprintf( '%s-%s-00.png', ...
            snapshotname, stageTimeToText( t ) );
    end
end