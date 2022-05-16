function resetGlobals()
%resetGlobals()
%   Force a reinitialisation of GFtbox's global variables.  This only needs
%   to be called if you have edited setGlobals.m and want to establish
%   the new values.  Otherwise, setGlobals() should be called, which
%   initialises the globals only the first time it is called in a Matlab
%   session.

    global gHaveGlobals GFTboxConfig;
    gHaveGlobals = [];
    setGlobals();
    GFTboxConfig = readGFtboxConfig();
end
