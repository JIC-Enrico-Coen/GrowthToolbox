function p = GFtboxPath()
    f = which('GFtbox_config.txt');
    if isempty(f)
        fprintf( 1, ...
            ['%s: Cannot find GFtbox directory.  Find it manually, cd to it,\n', ...
             'and then give this command again.\n' ], ...
            mfilename() );
        return;
    end
    gftboxDir = fileparts(f);
    p = adddirstopath( gftboxDir, '/\.', '/Motifs', 'GrowthToolbox/docs' );
end
