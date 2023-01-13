function d = getMeshProjectDir( m )
%d = getMeshProjectDir( m )
%   Find the full path name of the project directory of the mesh m. If the
%   mesh is not part of a project, the result is empty.

    if ~isempty( m.globalProps.projectdir ) && ~isempty( m.globalProps.modelname )
        d = fullfile( m.globalProps.projectdir, m.globalProps.modelname );
    else
        d = '';
    end
end
