function [runname,rundesc] = MoveStagesToProject( m, runname )
%[runname,rundesc] = MoveStagesToProject( m )
%[runname,rundesc] = MoveStagesToProject( m, runname )
%
%   Move stage files from a specified run into the project. If no run is
%   specified, then a list dialog is opened for the user to select the run.
%
%   m can be either a mesh or the full pathname of a project.
%
%   The rundesc result is the one-line description of the run read from the
%   CommandLine.txt file in the run directory. If missing or empty, rundesc
%   defaults to runname.  rundesc is what is shown in the list dialog.
%
%   Both results are empty in the case of any problems.

    if ischar(m)
        ProjectDirectory = m;
    else
        ProjectDirectory = fullfile( m.globalProps.projectdir, m.globalProps.modelname );
    end

    if nargin < 2
        runname = '';
    end
    
    rundesc = '';
    if (nargin<1) || isempty( ProjectDirectory )
        ProjectDirectory = pwd;
    else
        ProjectDirectory = fullpath(ProjectDirectory,pwd);
    end
    
    RUNSDIR = 'runs';
    dirname = fullfile(ProjectDirectory,RUNSDIR);
    if exist( dirname, 'dir' ) ~= 7
        fprintf( 1, 'No runs directory in project %s\n', ProjectDirectory );
        runname = '';
        return;
    end
    
    if (nargin >= 2) && ~isempty(runname)
        rundesc = runname;
    else
        d = dir(dirname);
        dlen = length(d);
        runnames = cell( 1, dlen );
        rundescs = cell( 1, dlen );
        maxdesclength = 0;
        numruns = 0;
        for i = 1:dlen
            % Ignore unwanted directories.
            runname = d(i).name;
            if runname(1)=='.'
                continue;
            end
            
            fullrunname = fullfile(dirname,runname);
            
            % Ignore files.
            if ~exist( fullrunname, 'dir' )
                continue;
            end

            % Get the run description. This is contained in the first line
            % of a certain file in each run directory. If not present,
            % default to the run name.
            descFileName = 'CommandLine.txt';
            fh = fopen(fullfile(fullrunname,descFileName),'r');
            if fh == -1
                rundesc = runname;
            else
                rundesc = fgetl(fh);
                if iseof( rundesc )
                    rundesc = runname;
                end                
                fclose( fh );
            end

            % Record the run name and description.
            numruns = numruns+1;
            runnames{numruns} = runname;
            rundescs{numruns} = rundesc;
            maxdesclength = max( maxdesclength, length(rundesc) );
        end
        runnames( (numruns+1):end ) = [];
        rundescs( (numruns+1):end ) = [];
        if isempty(rundescs)
            fprintf( 1, 'No suitable files in directory %s\n', dirname );
            return;
        end
        charwidth = 6;  % pixels
        charheight = 18;  % pixels
        s = newlistdlg( 'PromptString', 'Select an experiment:', ...
                        'SelectionMode', 'single', ...
                        'ListString', rundescs, ...
                        'ListSize', [max(600,maxdesclength*charwidth),600] );
%                         'ListSize', max( [600,200], [maxdesclength*charwidth,numruns*charheight] ) );
        if isempty( s )
            return;
        end
        runname = runnames{s};
        rundesc = rundescs{s};
    end
    
    [~,ok] = leaf_loadrun( m, 'name', runname );
    if ~ok
        runname = '';
        rundesc = '';
    end
end
