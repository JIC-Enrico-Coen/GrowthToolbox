function [chosendir,ok] = getNewProjectDir( m, projectsdir, projectname, ask )
    ok = false;
    chosendir = '';
    
    global GFTboxConfig
    
    needAskForDir = isempty( projectname ) || isempty(projectsdir);

    if isempty( projectname )
        if ask
            foreColor = [0.9 1 0.9];
            backColor = [0.4 0.8 0.4];
            x = performRSSSdialogFromFile( ...
                    findGFtboxFile( 'guilayouts/projectname.txt' ), [], [], ...
                    @(h)setGUIColors( h, backColor, foreColor ) );
            if isempty(x)
                return;
            end
            projectname = [ x.prefix, x.basename, x.suffix ];
        else
            fprintf( 1, 'Must supply project name.\n' );
            return;
        end
    end
    
    if needAskForDir
        if ask
            defaultProjectsDir = projectsdir;
            if isempty( defaultProjectsDir )
                defaultProjectsDir = m.globalProps.projectdir;
            end
            if isempty( defaultProjectsDir )
                defaultProjectsDir = GFTboxConfig.defaultprojectdir;
            end
            while true
                projectsdir = uigetdir( defaultProjectsDir, 'Create model in directory:' );
                if projectsdir==0
                    return;
                end
                if isGFtboxProjectDir( projectsdir )
                    queryDialog( 1, 'Invalid directory', ...
                        'You cannot create a project inside another project directory.' );
                    continue;
                end
                projectfulldir = fullfile( projectsdir, projectname );
                if isGFtboxProjectDir( projectfulldir )
                    queryDialog( 1, 'Invalid directory', ...
                        'You cannot overwrite an existing project.' );
                elseif exist( projectfulldir, 'dir' )
                    queryDialog( 1, 'Invalid directory', ...
                        'You cannot overwrite an existing folder.' );
                elseif exist( projectfulldir, 'file' )
                    queryDialog( 1, 'Invalid directory', ...
                        'You cannot overwrite an existing file.' );
                else
                    break;
                end
            end
            chosendir = projectfulldir;
        else
            fprintf( 1, 'Must supply projects folder name.\n' );
            return;
        end
    else
        chosendir = fullfile( projectsdir, projectname );
    end
    
    ok = ~isempty(chosendir);
end
