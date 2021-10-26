function logClusterCommand( command, resultmsg )
    logh = fopen( fullfile( userHomeDirectory(), 'cluster_logfile.txt' ), 'a' );
    fprintf( logh, '%s\n    %s\n    %s\n', datestr(clock), command, resultmsg );
    fclose(logh);
end
