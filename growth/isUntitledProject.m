function isuntitled = isUntitledProject( m )
%isuntitled = isUntitledProject( m )
%   Determine whether m is a mesh belonging to the anonymous project.
%   The test is that its containing folder is the GFtbox config directory.
%   A mesh that belongs to a real project and a mesh that has never been
%   saved, even as the anonymous project, both return false.

    configdir = getGFtboxUserConfigDir();
    isuntitled = strcmp( m.globalProps.projectdir, configdir );
end
