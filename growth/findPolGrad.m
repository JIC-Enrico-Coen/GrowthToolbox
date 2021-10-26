function gp = findPolGrad( m, cis )
%gp = findPolGrad( m, cis )
%   Calculate the polarising gradient for growth in the specified cells of
%   the mesh, by default all of them.

    if size( m.morphogens, 2 ) < 3
        return;
    end
    if nargin < 2
        cis = 1:size( m.tricellvxs, 1 );
    end
    
    pol_mgen = FindMorphogenRole( m, 'POLARISER' );
    polariser = getEffectiveMgenLevels( m, pol_mgen );
    gp = zeros(length(cis),3);
    for ci=1:length(cis)
        vxs = m.tricellvxs(cis(ci),:);
        gp(ci,:) = -trianglegradient( m.nodes( vxs, : ), polariser( vxs ) );
    end
end
