function p = projectPath( m )
%p = projectPath( m )
%   Return the full path name of the project directory of m.  If m is empty
%   or does not belong to a project, p is empty.

    if isempty(m) || isempty(m.globalProps.projectdir) || isempty(m.globalProps.modelname)
        p = [];
    else
        p = fullfile( m.globalProps.projectdir, m.globalProps.modelname );
    end
end
