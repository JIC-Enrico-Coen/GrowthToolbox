function [g,g2] = mgenCellGradient( m, mgen, cis )
%[g,g2] = mgenCellGradient( m, mgen, cis )
%   For a mesh m, and morphogen field mgen defined at each vertex of m,
%   compute the gradient of mgen for each element.  mgen can be either a
%   morphogen index, a morphogen name, or a row or column vector of values,
%   one for each vertex.  This is calculated in the global frame.
%
%   If the g2 output argument is specified, then in addition the gradient
%   on each end face of the pentahedra will be returned, as an N*3*2
%   matrix.  This applies only to laminar meshes.

    if nargin < 3
        cis = 1:size(m.tricellvxs,1);
    end
    if (numel(mgen)==1) || ischar(mgen)
        mgen = FindMorphogenIndex( m, mgen );
        if isempty(mgen)
            return;
        end
        mgen = m.morphogens( :, mgen );
    end
    full3d = usesNewFEs( m );
    numelements = length(cis);
    g = zeros( numelements, 3 );
    if nargout >= 2
        g2 = zeros( numelements, 3, 2 );
    end
    if full3d
        fevxs = m.FEsets(1).fevxs;
        fenodes = m.FEnodes;
    else
        fevxs = m.tricellvxs;
        fenodes = m.nodes;
    end
    for i=1:numelements
        ci = cis(i);
        vxs = fevxs(ci,:);
        nodes = fenodes(vxs,:);
        mv = mgen(vxs);
        if nargout >= 2 % Old-style meshes only.
            prismnodes = m.nodes( [vxs*2-1, vxs*2], : );
            prismmv = [ mv, mv ];
        end
        % The negative signs below are because we adopt the convention that
        % gradient arrows point downhill.
        if full3d
            g(i,:) = -fitGradient( nodes, mgen(vxs) );
        else
            g(i,:) = -trianglegradient( nodes, mv );
            if nargout >=2
                g2(i,:,1) = -trianglegradient( prismnodes(1:3,:), prismmv(1:3) );
                g2(i,:,2) = -trianglegradient( prismnodes(4:6,:), prismmv(4:6) );
            end
        end
        if all(g(i,:)==0) && all( abs(nodes(:,2)) < 3 )
            xxxx = 1;
        end
    end
end

