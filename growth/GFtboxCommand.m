function bareExptID = GFtboxCommand( varargin )
    %function GFtboxCommand(...)
    %
    %   IGNORE ALL OF THESE COMMENTS. THEY ARE HOPELESSLY OUT OF DATE.
    %
    %For running growth models in batch modpasswe. Results are filed in a
    %subdirectory
    %ProjectName:Movies:experimentname:meshes   stores full mesh .mat files
    %
    %At the end of each stage/step the mesh is stored in a separate file.
    %In addition, the command line used to invoke GFtboxCommand
    %and a copy of the interaction function are saved in the experimentname directory.
    %
    %The meshes can be viewed using VMS (View Mesh System)
    %or VMSReport. They can also be moved into the project directory where
    %GFtbox will recognise them as 'Stages'.
    %
    %To run on the cluster you must have 
    %      1) Your cluster username.
    %      2) The cluster name, e.g. eslogin.uea.ac.uk.
    %and the following programs installed on your computer
    %      3) scp (for copying files between the local machine and the cluster)
    %      4) ssh (for executing commands on the cluster from the local machine)
    %These must be set up so that you can at your operating system command
    %prompt use scp and ssh to communicate with the remote machine without
    %having to type your password. Setting this up is beyond the scope of
    %the comments here, but in brief it involves using ssh-keygen and
    %ssh-copy-id. Google is your friend. So is the unix man command.
    %      
    %GFtboxCommand(...
    %    'Cluster',true/false   % Use the cluster. Default is true.
    %    'Project',your_project)here,...  % The project to be run. This can be either
    %                              a full path name or the base name of a
    %                              project contained in one of the user's
    %                              list of default project directories.
    %
    % Using time
    %    'Stages',[80,120,...]  % default, output at every iteration
    %                           % list of stages that are to be
    %                           % output.
    %    
    % Using steps
    %    'Steps', 20,...        % number of steps to be run
    %
    %    'Modeloptions', [], ...
    %
    %    'param',value          % Set a model parameter.
    %
    %                           %Sensitivity testing
    %                           %m.modeloptions.sensitivity.range
    %                           %m.modeloptions.sensitivity.index
    %                           this is a reserved  modeloptions field
    %                           that is recognised by GFtboxCommand.
    %                           To perform a sensitivity test, there must
    %                           be set of obj files in a directory called
    %                           objs. One obj per time step.
    %                           It is differences between the test sensitivity values
    %                           and these obj files that will be computed.
    %                           that will 
    %    'ExpID',name,          Not for general use. Used internally by GFtboxCommand
    %                           to label experiments as they are run on
    %                           the cluster
    %    'Matlab',modulename    Specifies which version of Matlab to use.
    %                           The value must be a valid argument to the
    %                           "module add" command on the cluster. To
    %                           determine all available versions of Matlab,
    %                           log in to the cluster and give the command:
    %                               module avail matlab
    %                           The default is 'matlab', which will select
    %                           the default version. A specific version
    %                           would be selected by e.g. 'matlab/2020a'.
    %
    %                           The value that you give will not be
    %                           checked by this procedure. If the version
    %                           specified is not available, then the
    %                           cluster job will terminate as soon as it
    %                           tries to load it.
    
    % When Matlab starts, the random number generator is set to a default
    % state, and always generates the same sequence of numbers. This
    % implies that if GFtboxCommand is the first command executed in a
    % Matlab session, it will always generate the same random run ID. To
    % prevent this we randomly initialise the generator.
    rng('shuffle');
    
    bareExptID = NaN;

    global ProjectName ...
           LocalProjectFullPath ...
           RemoteProjectFullPath ...
           RemoteProjectsDirectory ...
           RemoteArchitecture ...
           DryRun ...
           MatlabModule

    ProjectName = '';
    LocalProjectFullPath = '';
    RemoteProjectFullPath = '';
    RemoteProjectsDirectory = '';
    RemoteArchitecture = '';
    DryRun = false;
    experimentID = '';
    experimentUserID = '';
    
    if rem(nargin,2)
        dbstack();
        error('GFtboxCommand: arguments should be in pairs');
    end
    setFixedClusterDetails();
    repetitions = 1;
    parallelOptions = true;
    stages=[];
    usecluster = ~oncluster();
    fprintf('Start - %s\n',datestr(now));
    starttime=clock();
    MatlabModule = 'matlab';

    argStruct = safemakestruct( mfilename(), varargin );
    argNames = fieldnames( argStruct );
    for i=1:length(argNames)
        argname = argNames{i};
        argvalue = argStruct.(argname);
        switch upper(argname)
            case 'DRYRUN'
                DryRun = argvalue;
            case 'CLUSTER'
                usecluster = (isempty(argvalue) || argvalue) && ~oncluster();
            case 'PROJECT'
                ProjectName=argvalue;
            case 'REMOTEPROJECTS'
                RemoteProjectsDirectory=argvalue;
            case 'EXPID'
                experimentID = argvalue;
            case 'EXPUSERID'
                experimentUserID = argvalue;
            case 'CLUSTERTYPE'
                % The option should be 'PC' if the cluster is a Windows
                % machine. Any other value implies a *nix machine.
                RemoteArchitecture = upper(argvalue);
            case 'REPETITIONS'
                % The number runs to be performed with each set of parameters.
                repetitions = argvalue;
            case 'COMBINEOPTIONS'
                switch argvalue
                    case 'together'
                        parallelOptions = true;
                    case 'combine'
                        parallelOptions = false;
                    otherwise
                        error( 'Option ''combineoptions'' must be ''together'' or ''combine''. Value was ''%s''.\n', ...
                            argvalue );
                end
            case 'STAGES'
                stages = argvalue;
            case 'MATLAB'
                MatlabModule = ['matlab/' argvalue];
                
            case 'MODELOPTIONS'
                % A struct array that is an alternative to setting the
                % model options.
                % Allowed fields of the array are the names of all the
                % model options (case sensitive).
                % If this is a struct array, then a run will be made for
                % each element of the array.
                % NOT IMPLEMENTED
                
%                 modeloptionlist = opt;
            otherwise % It is assumed to be a model option. Ignore it here.
%                 isGFtboxCommandOption = false;
        end
%         if isGFtboxCommandOption
%             argStruct = rmfield( argStruct, argname );
%         end
    end
    
    if isempty( ProjectName )
        dbstack();
        error('''Project'' parameter absent.');
    end
    
    [LocalProjectFullPath,status] = findGFtboxProject( ProjectName, false, false );
    if isempty( LocalProjectFullPath )
        dbstack();
        error('Project ''%s'' not found, reason:\n    %s.', ProjectName, status );
    end
    [localProjectsDirectory,ProjectName] = dirparts( LocalProjectFullPath );
%     [localProjectsDirectory,~,~] = fileparts( LocalProjectFullPath );
    RemoteProjectFullPath = clusterfullfile( RemoteProjectsDirectory, ProjectName );
    % We now have these variables specifying the layout of the local and
    % remote files and directories:
    %   ProjectName: The name of the project on both local and remote
    %       machines. This is also the basename of the directory that is
    %       the project.
    %   LocalProjectFullPath: the full path name of the local project.
    %   localProjectsDirectory: the full path name of the directory
    %       containing the local project directory.
    %   RemoteProjectFullPath: the full path name of the remote project.
    %   RemoteProjectsDirectory: the full path name of the directory
    %       containing the remote project directory.
    % In addition, these locations are fixed:
        % In the remote user's home directory.
    ClusterProjectFiles = 'ClusterFiles';
    LocalClusterProjectFiles = fullfile( LocalProjectFullPath, ClusterProjectFiles );
    if ~DryRun
        [ok,~,~] = mkdir( LocalClusterProjectFiles );
        if ~ok
            error( 'Cannot make local output directory %s', LocalClusterProjectFiles );
        end
    end

    if isempty( experimentID )
        % This happens only if the runs are to be done on the local
        % machine. And even then this value of experimentID is never used.
        
        % Generate a name: the project name and a time stamp.
        experimentID = [ ProjectName, '-', datestr(now,'yyyymmdd_HHMMSS') ];
    end
    
    % Even if we are not going to run the model here, but submit it to the
    % cluster, we still need to load it, in order to determine the valid
    % options and the default time stamp. Actually, maybe this is pointless
    % and we should do this only when actually running the model.
    [m,ok] = leaf_loadmodel( [], ProjectName, localProjectsDirectory, 'rewrite', false);
    if ~ok
         error('Cannot load project %s', LocalProjectFullPath);
    end
    m = leaf_setproperty( m, 'staticreadonly', true, 'allowInteraction',true ); % prevent cross talk when on cluster
    m = leaf_reload( m, 'restart' , 'rewrite', false);
    m = leaf_setproperty( m, 'staticreadonly', true, 'allowInteraction',true ); % prevent cross talk when on cluster
    
    % Initialise the model, so that we can then extract all the range
    % variables.
    m = leaf_setproperty( m, 'IFsetsoptions', true );
    [m,ok] = leaf_dointeraction( m );
    if ~ok
        dbstack();
        error('Problem with the interaction function.');
    end
    
    % All of the options supplied to GFtboxCommand that have not been
    % recognised should be options of the model being run.
    haveModelOptions = ~isempty( m.modeloptions );
    if haveModelOptions
        modeloptions = intersectStruct( argStruct, fieldnames( m.modeloptions ) );
        unrecognisedoptions = setdiff( fieldnames( argStruct ), fieldnames( m.modeloptions ) );
        if ~isempty( unrecognisedoptions )
            fprintf( 2, '%s: Unrecognised options ''%s''.\n', mfilename(), joinstrings( ''', ''', unrecognisedoptions ) );
        end
        haveModelOptions = ~isempty( fieldnames(modeloptions) );
    end
    
    % Decide timestep, number of steps, and stages to save.
    if isempty( stages )
        timePerRun = modeloptions.stepsperrun * m.globalProps.timestep;
        m.stagetimes = timePerRun*(1:modeloptions.runsperset);
    end
    stages = m.stagetimes;
    
    % Combine the model options in all possible ways.
    variantFormat = 'V%03d';
    if haveModelOptions
        fns = fieldnames( modeloptions );
        nummodeloptions = length(fns);
        valuesperoption = ones(1,nummodeloptions);
        for i=1:nummodeloptions
            fn = fns{i};
            if iscell( modeloptions.(fn) )
                numvals = length(modeloptions.(fn));
                if numvals==1
                    modeloptions.(fn) = modeloptions.(fn){1};
                else
                    valuesperoption(i) = numvals;
                end
            end
        end

        optionnames = fieldnames(modeloptions);
        if parallelOptions
            nummodels = max( valuesperoption );
            vii = (1:nummodels)';
        else
            nummodels = prod( valuesperoption );
            vii = enumerateIndexes( valuesperoption );
        end
        allmodeloptions = emptystructarray( nummodels, fieldnames(modeloptions) );
        for i=1:nummodels
            ixs = vii(i,:);
            allmodeloptions(i) = selectOptions( optionnames, ixs, modeloptions );
        end
        for runindex=1:length(allmodeloptions)
            allmodeloptions(runindex).currentrun = sprintf( variantFormat, runindex );
        end
    else
%         allmodeloptions = struct();
        allmodeloptions = struct( 'currentrun', sprintf( variantFormat, 1 ) );
    end
    
    clusterExcludeOptions = { 'Cluster', 'RemoteProjects', 'ClusterType', 'CombineOptions', 'Repetitions', 'Matlab' };
    clusterArgstruct = safermfield( argStruct, clusterExcludeOptions );
    if haveModelOptions
        clusterArgstruct = safermfield( clusterArgstruct, fieldnames(allmodeloptions) );
    end
    clusterArgString = structToString( clusterArgstruct );
    bareExptID = joinNonemptyStrings( '_', { experimentUserID, sprintf('%06d',floor(1000000*rand())) } );
    exptID = ['_e' bareExptID ];
    fprintf( 1, 'Run ID %s\n', exptID );
        
    if usecluster
        getClusterDetails();
        remoteProjectExists = existsRemoteFile( RemoteProjectFullPath );
        remoteClusterProjectFiles = clusterfullfile( RemoteProjectFullPath, ClusterProjectFiles );
        makeRemoteDirectory( remoteClusterProjectFiles );
        
        if remoteProjectExists
            fprintf( 1, 'Remote project %s exists, not copying across.\n', RemoteProjectFullPath );
        else
            % Copy the local project files across.

            makeRemoteDirectory( clusterfullfile( RemoteProjectFullPath, 'runs' ) );
            localProjectInfoFile = fullfile( LocalClusterProjectFiles, 'ProjectInfo.txt' );
            remoteProjectInfoFile = clusterfullfile( remoteClusterProjectFiles, 'ProjectInfo.txt' );
            writefile( localProjectInfoFile, [LocalProjectFullPath newline] );
            copyFileLocalRemote( localProjectInfoFile, remoteProjectInfoFile, '>', true );
            copyProjectFile( [makeIFname(ProjectName),'.m'] );
            copyProjectFile( [ProjectName,'.mat'] );
            copyProjectFile( [ProjectName,'_static.mat'] );
            
%             objflag = false;
            localObjDirectory = fullfile(LocalProjectFullPath,'objs');
            objlist = dir(fullfile(localObjDirectory,'*.obj'));
            remoteObjDirectory = clusterfullfile( RemoteProjectFullPath, 'objs' );
            if ~isempty(objlist) && ~existsRemoteFile( remoteObjDirectory )
                % There are local obj files but no remote objs directory.
                % Make it and copy the obj files across.
                makeRemoteDirectory( remoteObjDirectory );
%                 objflag = true;
                for i = 1:length(objlist)
                    objfilename = objlist(i).name;
                    copyFileLocalRemote( ...
                            fullfile(localObjDirectory,objfilename), ...
                            clusterfullfile( RemoteProjectFullPath, 'objs', objfilename ), ...
                            '>' );
                end
            end
        end
        
        if ~existsRemoteFile( 'RunSilent.m' )
            rs = which('RunSilent');
            copyFileLocalRemote( rs, 'RunSilent.m', '>' );
        end
        executeRemote( sprintf( 'touch ''%s''', 'ClusterBuffer.txt' ) );
        
        writefile( fullfile( LocalClusterProjectFiles, 'batchnumber.txt' ), [ exptID newline ] );

        
        
        sh_basefilename = [ProjectName, exptID,'.sh'];
        sh_fullfilename = fullfile( LocalClusterProjectFiles, sh_basefilename );
        report_basefilename = [ProjectName, exptID,'.txt'];
        report_fullfilename = fullfile( LocalClusterProjectFiles, report_basefilename );
        
        numruns = repetitions * length(allmodeloptions);
        subfilename = cell( 1, numruns );
        runnum = 0;
        for i=1:length(allmodeloptions)
            currentrun = allmodeloptions(i).currentrun;
            modeloptionsString = structToString( safermfield( allmodeloptions(i), 'currentrun' ) );
            subexptID = [ exptID '_' currentrun ];
            fprintf( 1, 'Options for run %d, subexptID %s:\n', i, subexptID );
            disp( allmodeloptions(i) );
            for repnum=1:repetitions
                runnum = runnum+1;
                ID = [ProjectName,subexptID,'R',sprintf('%03d',repnum)];
                moreargs = struct( 'currentrun', ID );
                moreargsstring = structToString( moreargs );
                temp_argument_list = [clusterArgString, ', ', modeloptionsString, ', ', moreargsstring, ', ''ExpID'', ''', ID, ''''];
                fprintf( 1, 'temp_argument_list = %s\n', temp_argument_list );
                [~,subfilename{runnum}] = unixtemplate( repnum, temp_argument_list, subexptID );
            end
        end
        if ~DryRun
            h_master=fopen(sh_fullfilename,'w');
            h_report=fopen(report_fullfilename,'w');
            fprintf(h_master,'#!/bin/bash\n');
%             fprintf(h_master,'. /etc/profile\n');  % To make sbatch visible. Might not be necessary
            for i=1:numruns
                fprintf(h_master,'sbatch < %s\n',subfilename{i});
                fprintf(h_report,'%s,\t,GFtboxCommand(%s);\n',subfilename{i},temp_argument_list);
            end
            fclose(h_master);
            fclose(h_report);
            ok = sendShellScript( sh_fullfilename, ['./' sh_basefilename], true );
        end
    else
        m = leaf_loadmodel( [], ProjectName, localProjectsDirectory, 'rewrite', false);
        m = leaf_setproperty( m, 'staticreadonly', true, 'allowInteraction', true ); % prevent cross talk when on cluster
        m = leaf_reload( m, 'restart' , 'rewrite', false);
        m = leaf_setproperty( m, 'staticreadonly', true, 'allowInteraction', true ); % prevent cross talk when on cluster
        
        numruns = repetitions * length(allmodeloptions);
        subfilename = cell( 1, numruns );
        runnum = 0;
        for i=1:length(allmodeloptions)
            currentrun = allmodeloptions(i).currentrun;
            modeloptionsString = structToString( safermfield( allmodeloptions(i), 'currentrun' ) );
            subexptID = [ exptID '_' currentrun ];
            fprintf( 1, 'Options for run %d, subexptID %s:\n', i, subexptID );
            disp( allmodeloptions(i) );
            for repnum=1:repetitions
                runnum = runnum+1;
                ID = [ProjectName,subexptID,'R',sprintf('%03d',repnum)];
                moreargs = struct( 'currentrun', ID );
                moreargsstring = structToString( moreargs );
                temp_argument_list = [clusterArgString, ', ', modeloptionsString, ', ', moreargsstring, ', ''ExpID'', ''', ID, ''''];
                fprintf( 1, 'temp_argument_list = %s\n', temp_argument_list );
%                 [~,subfilename{runnum}] = unixtemplate( repnum, temp_argument_list, subexptID );
                % currentrun
                m = leaf_setproperty( m, 'currentrun', ID ); % Give the model access to which run it is executing.
                    % This also tells it not to save stages to the project
                    % directory, only to the run directory.
                m = initialiseOptions( m );
                if haveModelOptions
                    m = setModelOptions( m, allmodeloptions(i) ); 
                    fprintf( 1, 'Model options specified:\n' );
                    disp( modeloptions );
                else
                    fprintf( 1, 'No model options specified, running with defaults.\n' );
                end
                printModelOptions( 1, m );
                doOneRun( m, stages, ID );
            end
        end
    end
    fprintf('Finish - %s\n',datestr(now));
    fprintf('Elapsed time = %d seconds\n',round(etime(clock(),starttime)));
end

function m = initialiseOptions( m )
    m = leaf_setproperty( m, 'IFsetsoptions', true );
    m = leaf_dointeraction( m );
    m = leaf_setproperty( m, 'IFsetsoptions', false );
end

function ok = copyProjectFile( filename )
% Copy the named file, which should be present in the local project
% directory, into the remote project directory.

    global LocalProjectFullPath RemoteProjectFullPath
    localFullPath = fullfile( LocalProjectFullPath, filename );
    remoteFullPath = clusterfullfile( RemoteProjectFullPath, filename );

    ok = copyFileLocalRemote( localFullPath, remoteFullPath, '>' );
end

function doOneRun( m, stages, runname )
% This is the procedure that actually runs the simulation. It may be
% running on either the desktop machine or the cluster.

    global ProjectName LocalProjectFullPath DryRun
    
    fprintf( 1, 'doOneRun called for run "%s".\n', runname );
    if DryRun
        fprintf( 1, 'Dry run only, no run performed.\n' );
        return;
    end
    % Choose a unique name for the runs subdirectory to store the results
    % of the current run.
    %
    % Normally we would force
    % this to be the name of a folder not currently existing, by using
    % newfilename(), but for concurrent runs on the cluster, this will not
    % work. This procedure may be called many times concurrently,
    % and it is important that no two instantiations choose the same name.
    % Therefore we obtain uniqueness by suffixing a UUID to experimentID.
    % AMENDED: We do not add a UUID as I'm not sure it's needed. We will
    % see. The UUID would be obtained from char(java.util.UUID.randomUUID).
    
    localExperimentUniqueFullPath = fullfile(LocalProjectFullPath, 'runs', runname);
    fprintf('Run directory: %s\n',localExperimentUniqueFullPath);
    [~,~,~] = mkdir(localExperimentUniqueFullPath);
    
    % Record the run parameters in the run directory.
%     writefile( fullfile(LocalExperimentUniqueFullPath,'CommandLine.txt'), varargsToString( varargin, { 'STAGES', 'CLUSTER', 'PROJECT' } ) );
    % Copy the interaction function to the run directory.
    ifname = makeIFname( ProjectName );
    ifFullname=fullfile( LocalProjectFullPath, [ifname,'.m'] );
    if exist(ifFullname,'file')==2
        copyfile(ifFullname, fullfile(localExperimentUniqueFullPath,[ifname,'.txt']));
    end
    
    m = leaf_setproperty( m, 'staticreadonly', true , 'allowInteraction', true ); % Prevent crosstalk between multiple jobs on the cluster.
    m = leaf_deletestages( m, 'stages', true, 'times', true );
    
    % Seed the random number using time and filename, to ensure different random numbers for each
    % instance running on the cluster.
    seednumber = sum(10000*clock()) + sum(double(localExperimentUniqueFullPath));
    rng(seednumber,'twister');
    rngstate = rng();
    fprintf( 2, 'Random seed = %d\n', rngstate.Seed );
    m = savemesh( m, ProjectName, localExperimentUniqueFullPath );
    m = savepng( m, localExperimentUniqueFullPath );

    for i_stage=1:length(stages)
        while meshBeforeTime( m, stages(i_stage) ) % realtime<stages(i_stage)
            m = leaf_iterate( m, 1, 'plot', 0 );
        end
        m=savemesh( m, ProjectName, localExperimentUniqueFullPath );
        m=savepng( m, localExperimentUniqueFullPath );
    end
end


function [errors,local_sh_basefilename] = unixtemplate(n,argsstring,batchnumberstr)
% This is called exactly once. Its purpose is to run a single call of RunSilent on
% the cluster. To do this it writes a .sh file locally, then copies it to
% the cluster, makes it writable and executable there, and converts
% line endings from dos to unix. It does not execute the file remotely.
%
% ProjectName and batchnumberstr are used to construct the name of the .sh
% file.

    global ProjectName LocalProjectFullPath RemoteProjectFullPath MatlabModule
    
    % This file should be created in the local project directory in the
    % cluster subdirectory.
    jobname = sprintf( '%s%sR%03d', ProjectName, batchnumberstr, n );
    local_sh_basefilename = sprintf( '%s.sh', jobname );
    local_sh_fullfilename = fullfile( LocalProjectFullPath, local_sh_basefilename );
    remote_sh_fullfilename = local_sh_basefilename;
    h = fopen( local_sh_fullfilename, 'w' );
    fprintf(h,'#!/bin/bash\n');
    
    % The next few lines write shell comments to the file. This file will
    % not be directly executed, but provided as input to sbatch on
    % the cluster.
    fprintf(h,'#SBATCH -p compute-24-96\n');
    outputDirBase = clusterfullfile( RemoteProjectFullPath, 'runs', jobname );
    fprintf(h,'#SBATCH --job-name %s\n',jobname);  % Specifies the name of the job.
    fprintf(h,'#SBATCH -t 24:00:00\n');  % 24 hour cpu time limit.
    fprintf(h,'#SBATCH -o %s.out\n',outputDirBase);  % Specifies the file to receive the standard output of the job.
    fprintf(h,'#SBATCH -e %s.err\n',outputDirBase);  % Specifies the file to receive the standard error output of the job.
    fprintf(h,'. /etc/profile\n');
    fprintf(h,'echo "%s starting at `date` in directory `pwd`"\n', mfilename());
    fprintf(h,'module add %s\n', MatlabModule);
    fprintf(h,'matlab -nosplash -nodesktop -nodisplay -nojvm -singleCompThread -r "RunSilent(%s); exit(0)"\n',argsstring);
    fprintf(h,'echo "%s ending at `date`"\n', mfilename());
    fclose(h);
    
    ok = sendShellScript( local_sh_fullfilename, remote_sh_fullfilename, false );
    errors = ~ok;
end

function ok = sendShellScript( localfullname, remotefullname, execute )
    ok = copyFileLocalRemote( localfullname, remotefullname, '>', true );
    if ok
        ok = executeRemote( sprintf( 'chmod +wx ''%s''', remotefullname ) );
    end
    if ok
        ok = executeRemote( sprintf( 'dos2unix ''%s''', remotefullname ) );
    end
    if ok && execute
        ok = executeRemote( sprintf( '''%s''', remotefullname ) );
    end
end

function m = savemesh(m,ProjectName,localExperimentUniqueFullPath)
    saveasbase = (m.globalProps.allowsave && (m.globalDynamicProps.currentIter==0));
    if saveasbase
        return;
    end
    stagesuffix = makestagesuffixf( m.globalDynamicProps.currenttime );
    savedir = fullfile( localExperimentUniqueFullPath, 'meshes' );
    [~,~,~] = mkdir( savedir );
    savefilebasename = [ProjectName stagesuffix];
    savefilename = fullfile( savedir, savefilebasename );
    ok = savemodelfile( m, savefilename, false, false, false );
    if ok
        fprintf( 1, 'Saved stage to %s\n', savefilename );
    else
        fprintf( 1, 'Could not save stage to %s\n', savefilename );
    end
end

function m = savepng(m,localExperimentUniqueFullPath)
    
    if ~oncluster()
        stagesuffix = makestagesuffixf( m.globalDynamicProps.currenttime );
        imagesDir = fullfile( localExperimentUniqueFullPath, 'images' );
        [~,~,~] = mkdir( imagesDir );
        printfilename = fullfile( imagesDir, sprintf('E%s.png',stagesuffix) );
        oldPPM = get(gcf,'PaperPositionMode');
        newPPM = 'auto';
        set(gcf,'PaperPositionMode',newPPM);
        fprintf( 1, 'PaperPositionMode: old %s, new %s\n', oldPPM, newPPM );
        fprintf( 1, 'Saving image to %s\n',printfilename);
        if ispc()
            m=leaf_plot(m,'invisibleplot',true,'uicontrols', false);
            print(gcf,'-dpng',printfilename);
        else
            m=leaf_plot(m,'invisibleplot',true,'uicontrols', false);
            print(gcf,'-dpng','-noui',printfilename);
        end
        fprintf('Saved image to %s\n',printfilename);
    end
end


function oc = oncluster()
% A very crude test to determine if we are running on the cluster.

    oc = contains( userHomeDirectory(), '/gpfs/home/' );
end


function s = structToString( str )
    fns = fieldnames(str);
    numfields = length(fns);
    args = cell(1,2*numfields);
    args(1:2:end) = fns;
    for i=1:numfields
        args{2*i} = str.(fns{i});
    end
    s = varargsToString( args );
end


function s = varargsToString( args, exclude )
% If ARGS is a string it is returned unchanged.
% If ARGS is a cell array, it is converted to a struct.
% If ARGS is a struct, it is converted to a string that could be used to
% specify its values as named options on a command line.

    if ischar( args )
        s = args;
    else
        if nargin < 2
            exclude = {};
        end
        if iscell(args)
            args = safemakestruct( mfilename(), args );
        end
        fns = fieldnames(args);
        numfields = length(fns);
        numterms = numfields*2;
        argstrings = cell( 1, numterms );
        included = true( 1, numterms );
        for i=1:numfields
            fn = fns{i};
            j = i+i-1;
            if any( strcmpi( fn, exclude ) )
                included([j,j+1]) = false;
            else
                argstrings{j} = ['''',fn,''''];
                argstrings{j+1} = argToString( args.(fn) );
            end
        end
        s = betterjoin( argstrings(included), ', ' );
    end
end

function s = argToString( arg )
    if iscell(arg)
        ss = cell(1,length(arg));
        for k=1:length(arg)
            ss{k} = argToString1( arg{k} );
        end
        s = [ '{', betterjoin(ss,', '), '}'];
    else
        s = argToString1( arg );
    end
end

function s = argToString1( arg )
    if ischar(arg)
        s=['''',arg,''''];
    elseif length(arg)==1
        s=num2str(arg);
    else
        minarg = min(arg);
        maxarg = max(arg);
        arg1 = linspace( minarg, maxarg, length(arg) );
        argrange = maxarg - minarg;
        if max(abs(arg1-arg)) <= argrange*1e-8
            if minarg==maxarg
                s = [ 'linspace( ' num2str(minarg) ', ' num2str(maxarg) ', ' num2str(length(arg)) ' )' ];
            else
                s = [ num2str(minarg) ':' num2str(argrange/(length(arg)-1)) ':' num2str(maxarg) ];
            end
        else
            s = [ '[' num2str(arg) ']' ];
        end
    end
end

function ss = betterjoin( varargin )
    ss = join( varargin{:} );
    if iscell(ss)
        ss = ss{1};
    end
end

function selectedOptions = selectOptions( optionnames, optionIndexes, optionStruct )
    numoptions = length( optionnames );
    if length(optionIndexes)==1
        optionIndexes = optionIndexes + zeros(1,numoptions);
    end
    for j=1:numoptions
        optname = optionnames{j};
        optvalues = optionStruct.(optname);
        if iscell( optvalues )
            optindex = optionIndexes(j);
            selectedOptions.(optname) = optvalues{ min(optindex,length(optvalues)) };
        else
            selectedOptions.(optname) = optvalues;
        end
    end
end

