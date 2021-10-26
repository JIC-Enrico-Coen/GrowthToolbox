function getClusterDetails( reload )
%getClusterDetails( reload )
%   Get the address of the cluster, the remote username, and the remote
%   user's password. These will be stored in the global variables
%   ClusterName and RemoteUserName.
%
%   If the global variables are all nonempty and RELOAD is either not
%   supplied or false, then the details will not be reread.

    global ClusterName RemoteUserName
    
    if nargin < 1
        reload = false;
    end
    
    gftboxConfig = readGFtboxConfig( reload );
    if isfield( gftboxConfig, 'remotehost' )
        ClusterName = gftboxConfig.remotehost;
    end
    if isfield( gftboxConfig, 'remoteuser' )
        RemoteUserName = gftboxConfig.remoteuser;
    end
    if ~isempty( ClusterName ) && ~isempty( RemoteUserName )
        reload = false;
    end
    
    if reload || isempty( ClusterName )
        ClusterName = input( 'Cluster name (e.g. foo.uea.ac.uk): ', 's' );
    end
    
    if reload || isempty( RemoteUserName )
        RemoteUserName = input( ['Username on ' ClusterName ': '], 's' );
    end
    
    setFixedClusterDetails( reload );
end
