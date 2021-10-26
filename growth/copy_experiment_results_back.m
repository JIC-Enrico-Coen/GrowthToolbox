function results_retrieved=copy_experiment_results_back(ProjectName,ExperimentName, StopHandle)

% ProjectName is the name of a project.
% ExperimentName is
    if nargin<3
        StopHandle=[];
    end
    MiddleName='runs';
    if nargin<2
        % directory of experiments
        command = sprintf('ls %s/runs;', ProjectName);
        [~,~,messg] = executeRemote( command );
        if exist(fullfile(ProjectName,'runs'),'dir')~=7
            mkdir(fullfile(ProjectName,'runs'));
        end
        ind=strfind(messg,newline);
    else
        if contains(ExperimentName,'*') 
            % there is a wildcard so find all the matching filenames
            % directory of experiments
            command = sprintf('ls %s/runs;', ProjectName);
            [~,~,messg] = executeRemote( command );
            [~,~,~] = mkdir(fullfile(ProjectName,'runs'));
            ind=strfind(messg,ExperimentName(1:(end-1))); % end-1 removes a newline.
            counter=0;
            ss = cell( 1, length(ind) );
            for i=1:length(ind)
                tempmessg=messg(ind(i):end);
                endline=strfind(tempmessg,[':',newline]);
                if isempty(endline)
                    indx=strfind(tempmessg,newline);
                    if isempty(indx)
                        ss{i}=tempmessg;
                    else % assume newline is at the end
                        ss{i}=tempmessg(1:indx-1);
                    end
                else
                    ss{i}=tempmessg(start:endline-1);
                end
                counter=counter+1;
            end
            ind=1:counter;
            messg='';
        else
            if strcmp(ExperimentName(end-3:end),'_000')
                messg=ExperimentName(1:end-4);
            else
                messg=ExperimentName;
            end
            ind=length(messg)+1;
        end
    end
    results_retrieved = cell( 1, length(ind) );
    start=1;
    for i=1:length(ind)
        if isempty(messg)
            s=ss{ind(i)};
        else
            s=messg(start:ind(i)-1);
        end
        ExperimentName=strtrim(s);
        start=ind(i)+1;
        fprintf('copying the files in %s',ExperimentName);
        command = sprintf('ls %s/runs/%s/meshes;', ProjectName,ExperimentName);
        [~,~,messg2] = executeRemote( command );
        % make the requisite directory in runs
        n=fullfile(ProjectName,'runs',ExperimentName);
        if exist(n,'dir')~=7
            mkdir(n);
        end
        if exist(fullfile(ProjectName,'runs',ExperimentName,'meshes'),'dir')~=7
            mkdir(fullfile(ProjectName,'runs',ExperimentName,'meshes'));
        end
        % copy the metadata files for the experiment
        localfile = fullfile( ProjectName, MiddleName, ExperimentName );
        remotefile = clusterfullfile( ProjectName,MiddleName,ExperimentName, '*.txt' );
        copyFileLocalRemote( localfile, remotefile, '<' );
        command = sprintf('rm -rf %s/runs/%s/*.txt;', ProjectName,ExperimentName);
        executeRemote( command );
        
        MiddleName='runs';
        ind2=strfind(messg2,newline);
        start2=1;
        results_retrieved1 = cell(1,length(ind2));
        kk=0;
        for j=1:length(ind2)
            if ~isempty(StopHandle)
                bkc=get(StopHandle,'BackgroundColor');
                if bkc(1)==1
                    break
                end
            end
            s2=strtrim(messg2(start2:ind2(j)-1));
            start2=ind2(j)+1;
            fprintf('copying file %s %s',ExperimentName,s2);
            localfile = fullfile(ProjectName,MiddleName,ExperimentName,'meshes',s2);
            remotefile = clusterfullfile( ProjectName,MiddleName,ExperimentName, s2 );
            [errors,~,~] = copyFileLocalRemote( localfile, remotefile, '<' );
            
            if ~errors
                kk=kk+1;
                results_retrieved1{kk}=fullfile(ExperimentName,'meshes',s2);
                command = sprintf('rm -f %s;', clusterfullfile( ProjectName,MiddleName,ExperimentName,'meshes',s2 ));
                executeRemote( command );
            end
        end
        results_retrieved1( (kk+1):end ) = [];
        results_retrieved{i} = results_retrieved1;
        if ~isempty(StopHandle)
            if ishandle(StopHandle)
                bkc=get(StopHandle,'BackgroundColor');
                if bkc(1)==1
                    break
                end
            end
        end
    end
    results_retrieved = horzcat( results_retrieved{:} );
end
