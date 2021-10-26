function l = getEffectiveMgenLevels( m, n, vxs )
    i = FindMorphogenIndex( m, n );
    if isempty(i)
        l = zeros(size(m.morphogens,1),0);
    else
        if nargin < 3
            vxs = 1:size(m.morphogens,1);
        end
        l = m.morphogens(vxs,i);
        if size(m.mgenswitch,1)==1
            a = repmat( m.mgenswitch(i), numel(vxs), 1 );
        else
            a = m.mgenswitch(vxs,i);
        end
        if m.allMutantEnabled
            a = a .* repmat( m.mutantLevel(i), numel(vxs), 1 );
        end
        l = l .* a;
    end
end
