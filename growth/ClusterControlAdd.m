function ClusterControlAdd(varargin)
%ClusterControlAdd(varargin)
%   Options:
%   'Project'  The name of the GFtbox project.
%   'FromBuffer'   ????

    if isempty(findobj('Name','ClusterMonitor'))
        ClusterMonitor;
    end
    projectnamecell={};
    frombuffercell={};
    arglist=varargin;
    if rem(length(arglist),2)~=0
        error('Please supply argument pairs, e.g. ''Project'',''motif'',''Pathname'',pwd');
    end
    for i=1:2:length(arglist)
        arg=lower(arglist{i});
        opt=arglist{i+1};
        switch arg
            case 'project'
                projectnamecell={opt};
            case 'frombuffer'
                frombuffercell=opt;
        end                
    end
    if isempty(frombuffercell)
        AddToClusterBuffer(projectnamecell);
        ClusterMonitor('StackPop','Add',projectnamecell)
    else
        ClusterMonitor('StackPop','Add',frombuffercell)
    end
end

function  AddToClusterBuffer(projectnamecell)
% Download ClusterBuffer.txt from the cluster, append every element of
% projectnamecell to it, one per line, copy the result back to the cluster,
% and delete the local copy.

    clusterBufferName = 'ClusterBuffer.txt';
    
    localfile = fullfile( userHomeDirectory, clusterBufferName );
    remotefile = clusterBufferName;
    executeRemote( sprintf( 'touch ''%s''', remotefile ) );
    copyFileLocalRemote( localfile, remotefile, '<' );
    
    h=fopen(localfile,'a');
    if h==-1
        error('%s: Problem opening %s.', mfilename, clusterBufferName );
    else
        fprintf(h,'%s\n',projectnamecell{:});
        fclose(h);
        copyFileLocalRemote( localfile, remotefile, '>', true );
    end
end
   
