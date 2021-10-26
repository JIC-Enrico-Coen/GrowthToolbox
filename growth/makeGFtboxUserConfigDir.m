function [configdir,ok,msg] = makeGFtboxUserConfigDir()
%[configdir,ok,msg,msgid] = makeGFtboxUserConfigDir()
%   Make the GFtbox config directory if it does not exist.  configdir
%   contains the full path name of the directory.  ok is true if it exists
%   or is successfully created.

    configdir = getGFtboxUserConfigDir();
    [ok,msg,msgid] = mkdir( configdir );
end
