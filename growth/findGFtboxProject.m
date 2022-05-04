function [projectfullpath,status] = findGFtboxProject( projectname, create, createProjectsDir )
%[projectfullpath,status] = findGFtboxProject( projectname, create, createProjectsDir )
%   Given the name of a project or a path to its directory, find the full
%   path. CREATE determines whether the directory will be created if it
%   does not exist. CREATEPROJECTSDIR determines whether a default
%   directory for containing projects should be created if one does not
%   exist.
%
%   If PROJECTNAME is a full path, if it is a GFtbox project directory,
%   that is the directory that is returned. If it is not, then an error is
%   returned. If it does not exist and CREATE is true, it is created, and
%   if that is successful, that directory is returned.
%
%   If PROJECTNAME is empty or not supplied, the project currently open in
%   GFtbox, if any, is used.
%
%   Otherwise, the procedure will search through all of the default project
%   directories as listed in ~/.GFtbox/GFtbox_config.txt, if any. If there
%   are none, then ~/GFtbox_Projects will be used as the default projects
%   directory. If it does not exist and CREATEPROJECTSDIR is true, it will
%   be created.
%
%   Then for each projects directory, the project will be searched for
%   there. The search stops when the first such directory is found. If it
%   is a GFtbox project directory, the full path is returned. If it exists
%   but is not a project directory, an error is returned.
%
%   If the project is not found in any of the projects directories, and
%   CREATE is true, the project directory is created in the first projects
%   directory.
%
%   CREATE and CREATEPROJECTSDIR default to false.
%
%   In case of error, PROJECTFULLPATH will be empty.
%
%   STATUS will be:
%
%       '' if an existing project directory is found or created.
%
%       'No open project' if no project name was given and no project was
%           open in GFtbox.
%
%       'Created [name]' if a new project directory is created.
%
%       'Could not create [name]' if a new project directory should have
%           been created but could not be.
%
%       'Project [name] not found' if there is no such directory (and
%           CREATE is false).
%
%       'Directory [name] is not a GFtbox project' if there is such a
%           directory, but it is not a GFtbox project (whether or not
%           CREATE is true).
%
%       'No projects directories'  There are no directories to search for
%           projects in, and CREATEPROJECTSDIR was false.
%
%       'Cannot make default projects directory [name]'  CREATEPROJECTSDIR
%           was true, a default projects directory was needed, but it could
%           not be created.

    projectfullpath = [];
    status = '';
    
    if nargin < 1
        projectname = '';
    end
    if (nargin < 2) || isempty( create )
        create = false;
    end
    if (nargin < 3) || isempty( createProjectsDir )
        createProjectsDir = false;
    end
    
    if isempty( projectname )
        [~,~,projectsdir,modelname,~] = GFtboxFindWindow();
        if isempty(modelname)
            status = 'No open project';
            return;
        end
        projectname = fullfile( projectsdir, modelname );
    end
    
    if isrootpath( projectname )
        if exist( projectname, 'dir' ) == 7
            if isGFtboxProjectDir( projectname )
                projectfullpath = projectname;
            else
                status = sprintf( 'Project %s not found', projectname );
            end
        elseif create
            [projectfullpath,status] = makeGFtboxProjectDir( projectname );
        else
            status = sprintf( 'Project %s not found', projectname );
        end
    else
        gftboxConfig = readGFtboxConfig( false, false );
        if isempty( gftboxConfig.projectsdir )
            if createProjectsDir
                homedir = getenv('HOME');
                newprojectsdir = fullfile( homedir, 'GFtbox_Projects' );
                [ok,msg,msgid] = mkdir( newprojectsdir );
                if ok
                    gftboxConfig.projectsdir = { newprojectsdir };
                else
                    status = sprintf( 'Cannot make default projects directory %s:\n    %s: %s\n', newprojectsdir, msgid, msg );
                    return;
                end
            else
                status = 'No projects directories';
                return;
            end
        end
        for i=1:length( gftboxConfig.projectsdir )
            dirname = gftboxConfig.projectsdir{i};
            testpath = fullfile( dirname, projectname );
            if exist( testpath, 'dir' ) == 7
                if isGFtboxProjectDir( testpath )
                    projectfullpath = testpath;
                    status = '';
                else
                    status = sprintf( 'Directory %s is not a GFtbox project', testpath );
                end
                return;
            end
        end
        if create
            testpath = fullfile( gftboxConfig.projectsdir{1}, projectname );
            [projectfullpath,status] = makeGFtboxProjectDir( testpath );
        else
            status = 'NOT FOUND';
        end
    end
end

function [projectfullpath,status] = makeGFtboxProjectDir( fullname )
    [ok,msg,msgid] = mkdir(fullname);
    if ok
        projectfullpath = fullname;
        status = sprintf( 'Created %s', fullname );
    else
        projectfullpath = [];
        status = sprintf( 'Could not create %s:\n    %s %s\n', fullname, msgid, msg );
    end
end
