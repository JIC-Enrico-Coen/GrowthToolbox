function configdir = getGFtboxUserConfigDir()
%configdir = getGFtboxUserConfigDir()
%   Return the full path to the GFtbox config directory.  No test is made
%   to see if it exists, nor any attempt to create it.

    homedir = userHomeDirectory();
    configdir = fullfile( homedir, '.GFtbox' );
end
