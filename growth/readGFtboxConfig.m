function gftboxConfig = readGFtboxConfig( force, verbose )
%gftboxConfig = readGFtboxConfig( force, verbose )
%   Read GFtbox config info from the global configuration file and the
%   current user's configuration file.
%
%   If the global variable GFTboxConfig is nonempty and FORCE is false,
%   then the value of GFTboxConfig is returned without consulting the
%   config files.
%
%   If the config files are consulted, the global variable GFTboxConfig is
%   updated.

    global GFTboxConfig

    if nargin < 1
        force = false;
    end
    if nargin < 2
        verbose = true;
    end
    
    if ~force && ~isempty( GFTboxConfig )
        gftboxConfig = GFTboxConfig;
        return;
    end
    
    gftboxDir = GFtboxDir();

    % Get config info.
    configFileBasename = 'GFtbox_config.txt';
    configFileFullname = fullfile( gftboxDir, configFileBasename );
    globalConfigStruct = structFromFile( configFileFullname );
    userConfigDir = makeGFtboxUserConfigDir();
    userConfigFilename = fullfile( userConfigDir, configFileBasename );
    
    gftboxConfig = structFromFile( userConfigFilename );
    gftboxConfig.defaultConfigFilename = configFileFullname;
    gftboxConfig.userConfigFilename = userConfigFilename;
    newfields = setdiff( fieldnames( globalConfigStruct ), fieldnames( gftboxConfig ) );
    if ~isempty( newfields )
        gftboxConfig = defaultFromStruct( gftboxConfig, globalConfigStruct );
    end
    gftboxConfig = convertFieldToNumber( gftboxConfig, 'revnum', '%d', 0 );
    gftboxConfig = convertFieldToNumber( gftboxConfig, 'FontSize', '%f', 0 );
    if isfield( gftboxConfig, 'dir' )
        % Obsolete field name.  Convert to 'projectsdir'.
        gftboxConfig.projectsdir = gftboxConfig.dir;
        gftboxConfig = rmfield( gftboxConfig, 'dir' );
    end
    gftboxConfig = defaultFromStruct( gftboxConfig, ...
        safemakestruct( mfilename(), ...
            'compressor', 'None', ...
           'projectsdir', {}, ...
     'defaultprojectdir', '', ...
         'recentproject', [], ...
                'revnum', 0, ...
               'revdate', '', ...
       'usegraphicscard', 'false', ...
      'bioedgethickness', 1, ...
         'biovertexsize', 1, ...
     'catchIFExceptions', 'true', ...
              'FontName', 'Helvetica', ...
             'FontUnits', 'pixels', ...
              'FontSize', 10, ...
            'FontWeight', 'normal', ...
             'FontAngle', 'normal', ...
              'Renderer', 'OpenGL', ...
            'remotehost', '', ...
            'remoteuser', '' ) );
    % If there is just one projectsdir, it will have been returned as a
    % string.  Make it a cell array with that string as its only element.
    if ischar( gftboxConfig.projectsdir )
        gftboxConfig.projectsdir = { gftboxConfig.projectsdir };
    end
    % Set defaultprojectdir to the last projectsdir with a * if any,
    % otherwise the first projectsdir.
    if ~isempty( gftboxConfig.projectsdir )
        gftboxConfig.defaultprojectdir = gftboxConfig.projectsdir{1};
    end
    for i=1:length( gftboxConfig.projectsdir )
        if regexp( gftboxConfig.projectsdir{i}, '^\*\s+' )
            gftboxConfig.projectsdir{i} = regexprep( gftboxConfig.projectsdir{i}, '^\*\s+', '' );
            gftboxConfig.defaultprojectdir = gftboxConfig.projectsdir{i};
        end
    end
    % Delete any nonexistent directories from projectsdir and defaultprojectdir.
    okdir = false( length(gftboxConfig.projectsdir) );
    for i=1:length( gftboxConfig.projectsdir )
        okdir(i) = exist( gftboxConfig.projectsdir{i}, 'dir' );
        if ~okdir(i)
            if verbose
                fprintf( 1, 'Projects directory %s does not exist.\n', gftboxConfig.projectsdir{i} );
            end
            if strcmp( gftboxConfig.projectsdir, gftboxConfig.defaultprojectdir )
                gftboxConfig.defaultprojectdir = '';
            end
        end
    end
    gftboxConfig.projectsdir = gftboxConfig.projectsdir(okdir);
    if isempty( gftboxConfig.projectsdir )
        % If there is no projectsdir, make one in the user's home directory.
        userhome = userHomeDirectory();
        defaultuserdir = fullfile( userhome, 'GFtbox_Projects' );
        [ok,msg,~] = mkdir( defaultuserdir ); % Unused: msgid
        if ok
            if verbose
                if isempty(msg)
                    fprintf( 1, 'No default user projects directory, created %s.\n', defaultuserdir );
                else
                    fprintf( 1, 'Found default user projects directory %s.\n', defaultuserdir );
                end
            end
            gftboxConfig.projectsdir = { defaultuserdir };
            gftboxConfig.defaultprojectdir = defaultuserdir;
        else
            if verbose
                fprintf( 1, 'No default user directory, and failed to create %s.\n', defaultuserdir );
            end
        end
    elseif isempty( gftboxConfig.defaultprojectdir )
        % The defaultprojectdir didn't exist.  Set it to the first
        % projectsdir.
        gftboxConfig.defaultprojectdir = gftboxConfig.projectsdir{1};
    end

    [revnum,revdate] = GFtboxRevision();
    if gftboxConfig.revnum ~= revnum
        gftboxConfig.revnum = revnum;
        gftboxConfig.revdate = revdate;
    end
    
    GFTboxConfig = gftboxConfig;
end

