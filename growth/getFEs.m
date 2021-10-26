function fes = getFEs( m, fei )
%fes = getFEs( m, fei )
%   Get the tuples of vertexes for the given FEs, by default all of them.

    if isVolumetricMesh( m )
        if nargin < 2
            fes = m.FEsets.fevxs;
        else
            fes = m.FEsets.fevxs(fei,:);
        end
    else
        if nargin < 2
            fes = m.tricellvxs;
        else
            fes = m.tricellvxs(fei,:);
        end
    end
end
