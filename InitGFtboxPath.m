function InitGFtboxPath( varargin )
% InitGFtboxPath()
%   Call this if you have never run GFtbox before. It will add all of the
%   GFtbox directories to your command path.  You must be in the main
%   GFtbox directory when you give this command.
%
%   This command only affects the path for the current Matlab session.  If
%   you want to have the GFtbox directories on the command path
%   permanently, then use the SAVEPATH command to save the current path.
%   This will avoid having to use the INITGFTBOX command again.
%
%   It is harmless, but unnecessary, to give this command if the GFtbox
%   directories are already on your command path.
%
%   InitGFtboxPath( 'remove' ) removes the GFtbox directories from the
%   command path instead.
%
%   InitGFtboxPath( 'save' ) causes the updated path to be saved. This
%   makes the new path automatically available on subsequent invocations of
%   Matlab without having to call this function again.
%
%   InitGFtboxPath( 'remove', 'save' ) removes the GFtbox directories from
%   the path and then saves the path.  The order of the arguments does not
%   matter.

% This function must only call functions which are either in this file, in
% the same directory, or in directories on the standard MATLAB command path.

    f = which('GFtbox.m');
    if isempty(f)
        fprintf( 1, ...
            ['%s: Cannot find GFtbox directory.  Find it manually, cd to it,\n', ...
             'and then give this command again.\n' ], ...
            mfilename() );
        return;
    end
    gftboxDir = fileparts(f);
    addpath( fullfile( gftboxDir, 'Utils' ) );
    addpath( fullfile( gftboxDir, 'Utils', 'UI' ) );
    p = getsubdirs( gftboxDir, ...
        '[/\\]\.', ...
        '[/\\]Models', ...
        '[/\\]Motifs', ...
        '[/\\]temp', ...
        'GrowthToolbox[/\\]docs', ...
        'GrowthToolbox[/\\]Papers' );
    
    save = false;
    remove = false;
    for i=1:nargin
        if strcmpi( varargin{i}, 'save' )
            save = true;
        elseif strcmpi( varargin{i}, 'remove' )
            remove = true;
        end
        % Unrecognised arguments are ignored.
    end
    
    if remove
        S = warning('OFF', 'MATLAB:rmpath:DirNotFound');
        rmpath(p);
        warning(S);
    else
        addpath(p);
    end
    if save
        savepath();
    end
    % fprintf( 1, 'The GFtbox directories have been added to the MATLAB command path.\n' );
end
