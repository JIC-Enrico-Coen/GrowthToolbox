function RunSilent(varargin)
%RunSilent( varargin )
%   Runs GFtboxCommand with the given arguments.
%   If the DArT_Toolshed is not on the path, assume it is directly under
%   the user's home directory.

    if isempty( which('GFtboxCommand') )
        disp('>>>>>> COULD NOT FIND TOOLSHED SO ADD IT TO PATH ')
        pathToToolshed='DArT_Toolshed';
        addpath(genpath(pathToToolshed));
    end
    disp('Starting GFtboxCommand');
    GFtboxCommand(varargin{:});
end