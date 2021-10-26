function ClusterMonitor(arg,opt,projectnamecell)
%function ClusterMonitor()
%
%   This starts a GUI for monitoring remote projects and retrieving their
%   results.

    getClusterDetails();

    if nargin<2
        opt=[];
    end
    if nargin<3
        projectnamecell={};
    end
    if nargin<1
        if isempty(findobj('Name','ClusterMonitor'))
            data=initialise;
            ClusterMonitor_fig=data.ClusterMonitor_fig;
            set(ClusterMonitor_fig,'CloseRequestFcn',[mfilename,'(''Quit'',0);']);
            
            guidata(ClusterMonitor_fig,data);
            
            RefreshProjectList( data );
            
%             [~]=ClusterBufferIO(data,'r');
        else
            disp('ClusterMonitor is already open.');
        end
    else
        ClusterMonitor_fig = findobj('Name','ClusterMonitor');
        data=guidata(ClusterMonitor_fig);
        if strcmpi(arg,'quit')
            stop(data.handles.timerhandle);
            [~]=timecontrol(data,false);
            delete(ClusterMonitor_fig);
            delete(timerfind);
        else
            switch lower(arg)
                case 'getlogs'
                    data=GetLogs(data);
                case 'gettimedresults'
                    try
                        if opt==0
                            % Invoked from GUI.
                            if ~haveExperiments()
                                return;
                            end
                            if ~isvalid(data.handles.timerhandle)
                                data.handles.timerhandle=timer;
                            end
                            data=timecontrol(data,1);
                        end
                            
                        TasksExecuted=get(data.handles.timerhandle,'TasksExecuted');
                        TasksToExecute=get(data.handles.timerhandle,'TasksToExecute');
                        set(data.handles.Counter,'String',sprintf('%3d/%3d gets',TasksExecuted,TasksToExecute));
                        set(data.handles.NextTime,'String',...
                            datestr(datenum(datestr(clock))+data.timer_interval/(60*60)/24,'HH:MM:SS'));
                            
                        if opt ~= 0
                            % Invoked by timer.
                            get(data.handles.timerhandle)
                            data=GetAllResults(data);
                        end
                    catch e
                        % Under what circumstances do we arrive here?
                        dbstack
                        e;
                        disp('Abandon data collection. Tidy up by removing handle to ClusterMonitor.');
                        set(0,'userdata',[]);
                    end
                case 'getresults'
                    data=GetSelectedResults(data);
                case 'button'
                    data=button(data);
%                 case 'stackpop'
%                     data=StackPop(data,opt,projectnamecell);
                case 'timecontrol'
                    data=timecontrol(data,opt);
            end
            if exist('ClusterMonitor_fig','var')==1
                if ishandle(ClusterMonitor_fig)
                    guidata(ClusterMonitor_fig,data);
                end
            end
            if isempty(projectnamecell) % i.e. only when ui has been used
                set(gcf,'Pointer','arrow');
%                 set(gco,'BackgroundColor',[0.9882    0.9961    0.7216]);%c);
            end
        end
    end    
end

function have = haveExperiments()
    s = get(data.handles.Outstandingexperiments,'String');
    have = ~isempty(s) && ~isempty(s{1});
end

function  data=timecontrol(data,opt)
    if opt
        % Start timer.
        if isvalid(data.handles.timerhandle)
            set(data.handles.timerhandle, 'ExecutionMode', 'FixedRate',...
                'TimerFcn',[mfilename,'(''GetTimedResults'',1);'],...
                'StopFcn',[mfilename,'(''timecontrol'',0);'],...
                'Period', data.timer_interval, ... %60*60*2,...
                'TasksToExecute',data.duration_of_looking); %48); % two days worth
            start(data.handles.timerhandle);
            if ishandle(data.handles.NextTime)
                set(data.handles.NextTime,'String',...
                    datestr(datenum(datestr(clock))+data.timer_interval/(60*60)/24,'HH:MM:SS'));
            end
        else
            set(data.handles.NextTime,'String','Off');
        end
    else
        % Stop timer.
        stop(data.handles.timerhandle);
        set(data.handles.NextTime,'String','Off');
    end
end

function data=initialise
    ClusterMonitor_fig = openfig(mfilename(), 'reuse');
    set(ClusterMonitor_fig,'Color',[252,254,184]/255);
    handles = guihandles(ClusterMonitor_fig);
    buttonCallback = [mfilename,'(''Button'');'];
    set(handles.deletesh,'callback',buttonCallback);
    set(handles.deleteproject,'callback',buttonCallback);
    set(handles.reportJobs,'callback',buttonCallback);
    set(handles.deleteprojectexperiments,'callback',buttonCallback);
    set(handles.refreshProjectList,'callback',buttonCallback);
    set(handles.GetResults,'callback',[mfilename,'(''GetResults'');']);
    set(handles.GetLog,'callback',[mfilename,'(''GetLogs'');']);
    set(handles.StopClock,'callback',[mfilename,'(''timecontrol'',false);']);
    set(handles.Outstandingexperiments,'String','');
    set( handles.Outstandingexperiments, 'Value', [] );
    
    data.handles=handles;
    data.handles.timerhandle=timer;
    data.duration_of_looking=60; %events
    data.timer_interval=15*60; %seconds
    data.ClusterMonitor_fig=ClusterMonitor_fig;
end

function data=GetLogs(data)
    s=get(data.handles.Outstandingexperiments,'String');
    if isempty(s) || isempty(s{1})
        return;
    end
    ind=get(data.handles.Outstandingexperiments,'Value');
    namelist=s(ind);
    fprintf('Retrieving logs:\n');
    fprintf('    %s\n', namelist{:} );

    for i=1:length(namelist)
        file=fullfile( data.CurrentProjectsDir, data.CurrentProjectName, 'ClusterFiles', [namelist{i},'.txt'] );
        tex = readFileToStrings( file );
        if isempty(tex)
            continue;
        end
        for j=1:length(tex)
            n=tex{j};
            SubmissionName=[n(1:(strfind(n,'.sh')+2)),'.o*'];  % MAGIC NUMBERS!!
                % I believe SubmissionName is supposed to have the form
                % [projectname]-e[EID]R[RID].out, i.e. it is the name of
                % the output file for a single run.
            commandline=n(strfind(n,'.sh')+6:end);   % MORE MAGIC NUMBERS!! This is supposed to get the GFtboxCommand call that ran this experiment.
            tailLogText = tailLogFile(SubmissionName);
            disp('--------------------------------------------')
            fprintf('tail of %s log\n %s',SubmissionName,commandline);
            disp('--------------------------------------------')
            fwrite( 1, tailLogText );
            disp('--------------------------------------------')
            ind1=regexpi(commandline,'ExpID'',''','end');
            tail=commandline((ind1+1):end);  % MAGIC NUMBERS!!
            ind2=regexpi(tail,'''');
            SubmissionNameX = SubmissionName(1:end-10);  % MAGIC NUMBERS!!
            ExperimentName=tail(1:(ind2-5));  % MAGIC NUMBERS!!
            ExperimentNameX = ExperimentName(1:end-3);
            
            % The above code is intended to extract the following
            % information about a single run:
            % ExperimentName:  [PN]-e[EID]  The name of the ensemble of runs.
            % ExperimentNameX: 
            % SubmissionName:  
            % SubmissionNameX: 
            
            fprintf('copy_experiment_results_back(''%s'',''%s'');',SubmissionNameX,ExperimentName);
            disp('--------------------------------------------')
        end
        fprintf('copy_experiment_results_back(''%s'',''%s*''); %% to copy some experiments back',SubmissionNameX,ExperimentNameX);
        fprintf('copy_experiment_results_back(''%s''); %% to copy all experiments back',SubmissionNameX);
        disp('--------------------------------------------')
    end
end

function data = GetSelectedResults(data)
    s = get(data.handles.Outstandingexperiments,'String');
    if isempty(s) || isempty(s{1})
        return;
    end
    ind = get(data.handles.Outstandingexperiments,'Value');
    namelist = s(ind);
    data = GetResults( data, namelist );
end

function data = GetAllResults(data)
    namelist = get(data.handles.Outstandingexperiments,'String');
    if isempty(namelist) || isempty(namelist{1})
        return;
    end
    data = GetResults( data, namelist );
end

function data=GetResults( data, namelist )
    namelist = s(ind);
    fprintf('Retrieving results:\n');
    fprintf('    %s\n', namelist{:} );

    for i=1:length(namelist)
        ProjectInstance = namelist{i};
        % ProjectInstance is expected to have the form
        % [ ProjectName '-eNNNNNN' ].
        ss = regexp( ProjectInstance, '^(.*)-e[0-9]+', 'match' );
        if isempty( ss )
            continue;
        end
        ProjectName = ss{1};
        remoteZipName = clusterfullfile(ProjectName,[ProjectInstance,'.zip']);
        remoteZipContents = clusterfullfile(ProjectName,'runs',[ProjectInstance,'*']);
        command = sprintf('zip -r "%s" "%";', remoteZipName, remoteZipContents );
        [ok,co] = executeRemote( command, true );
        if ok
            [~,~,~] = mkdir(fullfile(ProjectName,'runs'));
            localZipName = [ fullfile(ProjectName,'runs',ProjectInstance), '.zip' ];
            fprintf( 1, 'Getting remote zip file %s.zip\n', remoteZipName );
            copyFileLocalRemote( localZipName, remoteZipName, '<', [], true );
            fprintf( 1, 'Received remote zip file %s\n', remoteZipName );
            unzip( sprintf( '%s.zip', localZipName ), '.' );  % USES CURRENT DIRECTORY!! MUST NOT!!
        else
            fprintf( 1, 'Cannot make remote zip file. Output:\n%s', co );
        end
    end
end

function data=button(data)
    whichbutton = get( gcbo(), 'Tag' );
    switch whichbutton
        case 'deletesh'
            ClusterDELJOB();
        case 'deleteproject'
            ClusterDELPROJ( selectedProjects( data ) );
        case 'reportJobs'
            [~,co] = executeRemote( sprintf( '''. /etc/profile; bjobs''' ), true );
            if ~beginsWithString( co, 'No ' )
                fwrite( 1, ['Currently running cluster jobs:', newline] );
            end
            fwrite( 1, co );
        case 'deleteprojectexperiments'
            fprintf( 1, 'Delete runs directory in remote project %s\n', data.CurrentProjectName )
            ClusterDELEXP( selectedProjects( data ) );
        case 'refreshProjectList'
            RefreshProjectList( data );
    end
end

function projectList = selectedProjects( data )
    projectList = get( data.handles.Outstandingexperiments, 'String' );
    selected = get( data.handles.Outstandingexperiments, 'Value' );
    projectList = projectList( selected );
end

function RefreshProjectList( data, getruns )
% Update the listbox with a list of the projects currently existing on the
% remote machine, that have nonempty runs directories. Write to the console
% a list of all the projects and their runs directories.
%
%   getruns is not implemented. It is envisaged that it will get a list of
%   all runs of all projects.

    global RemoteProjectsDirectory

    % Get a list of all remote project directories. Each line will contain
    % a [PN].
    [ok,projects] = executeRemote( sprintf( 'ls -1 ''%s''', RemoteProjectsDirectory ), true );
    if ~ok
        projectlist = {};
    else
        projectlist = splitString( '\s+', projects );
        projectlist = sort( projectlist(:) )';
        projectlist = projectlist( isSafeFilename( projectlist ) );
    end
    
    
    
    
    
    
%     % Get a list of all runs directories. Each line will have the form
%     % [PN]-e[EID]R[RID]. We keep only the PN part.
%     [ok,runs] = executeRemote( sprintf( 'ls -1 ''%s/*/runs''', RemoteProjectsDirectory ), true );
%     
%     if ~ok
%         return;
%     end
%     runlist = splitString( '\s+', runs );
%     runlist = sort( runlist(:) )';
%     
%     projectlist = cell( 1, length(runlist) );
%     numprojects = 0;
%     lastproject = '';
%     projectindexes = zeros( 1, length(runlist) );
%     for i=1:length(runlist)
%         r = runlist{i};
%         x = regexp( r, '-e[0-9]+R[0-9]+' ); % Should end the pattern with '$', but need to eliminate the UUIDs first.
%         if ~isempty(x)
%             pn = r( 1:(x(1)-1) );
%             if ~strcmp(pn,lastproject) && isSafeFilename( pn )
%                 numprojects = numprojects+1;
%                 projectlist{numprojects} = pn;
%                 lastproject = pn;
%                 projectindexes(i) = numprojects;
%             end
%         end
%     end
%     projectlist( (numprojects+1):end ) = [];

    if isempty(projectlist)
        set( data.handles.Outstandingexperiments, 'String', {''} );
        set( data.handles.Outstandingexperiments, 'Value', 1 );
    else
        oldProjectList = get( data.handles.Outstandingexperiments, 'String' );
        oldSelected = get( data.handles.Outstandingexperiments, 'Value' );
        [~,~,newSelected] = intersect( oldProjectList(oldSelected), projectlist );
        if isempty(newSelected)
            if isempty(projectlist)
                newSelected = [];
            else
                newSelected = 1;
            end
        end
        set( data.handles.Outstandingexperiments, 'String', projectlist );
        set( data.handles.Outstandingexperiments, 'Value', newSelected );
    end
    
    fprintf( 1, '%s\n', projectlist{:} );
    
%     projectindex = 0;
%     for i=1:length(runlist)
%         if projectindexes(i)==0
%             continue;
%         end
%         if projectindexes(i) ~= projectindex
%             fprintf( 1, '%s\n', projectlist{projectindexes(i)} );
%             projectindex = projectindexes(i);
%         end
%         fprintf( 1, '    %s\n', runlist{i} );
%     end
end

