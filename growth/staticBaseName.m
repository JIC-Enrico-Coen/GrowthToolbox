function s = staticBaseName( m )
%s = staticBaseName( m )
%   If m is a string, return m concatenated with the static suffix and
%   '.mat.'  If m is a mesh, do the same with the model name, provided that
%   m belongs to a project; if not, return the empty string.

    if isempty(m)
        s = '';
        return;
    end
    if isstruct(m)
        if isempty(m.globalProps.projectdir)|| isempty(m.globalProps.modelname)
            s = '';
            return;
        end
        s = [ m.globalProps.modelname, '_static.mat' ];
    else
        s = [ m, '_static.mat' ];
    end
end
