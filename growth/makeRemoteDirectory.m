function ok = makeRemoteDirectory( remoteDir )
    ok = executeRemote( sprintf( 'mkdir -p ''%s''', remoteDir ) );
end
