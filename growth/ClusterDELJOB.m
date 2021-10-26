function ClusterDELJOB()
    global RemoteUserName
    getClusterDetails();
    
    remotecmd = sprintf( '''. /etc/profile; bkill -u %s 0 || true''', RemoteUserName );
    % The "|| true" part is to suppress an echoing of the whole command,
    % including the password, if there are no running jobs to kill.
    
    [~,commandoutput] = executeRemote( remotecmd, true );
    if ~isempty(commandoutput)
        fwrite( 1, commandoutput );
    end
end