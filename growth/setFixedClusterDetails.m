function setFixedClusterDetails( reload )
%setFixedClusterDetails( reload )
%   Set those globals that do not require reading the encrypted files.
%   A global will be set if either RELOAD is true or the global is empty.

    global RemoteProjectsDirectory ...
           RemoteArchitecture
    
    if nargin < 1
        reload = false;
    end
    
    if reload || isempty( RemoteProjectsDirectory )
        RemoteProjectsDirectory = 'GFtbox_Projects';
    end
    
    if reload || isempty( RemoteArchitecture )
        RemoteArchitecture = 'UNIX';
    end
end
