function m = addToNormal( m, addn, absolute )
%m = addToNormal( m, addn, absolute )
%   addn is a vector containing one value per node of m.
%   If absolute is true, then each node is displaced normal to the surface
%   by that amount.  If absolute is false (the default), then each node is
%   displaced normal to the surface by that proportion of the thickness at
%   that point.

    if ~m.globalProps.prismnodesvalid
        complain( 'addToNormal: prisms are not valid.\n' );
        return;
    end
    if nargin < 3
        absolute = false;
    end
    if absolute
        delta = m.prismnodes(2:2:end,:) - m.prismnodes(1:2:end,:);
        thicknesses = sqrt(sum(delta.^2,2));
        addn_rel = addn./thicknesses;
        addn_rel(isnan(addn_rel)) = 0;
        perturbations = delta .* repmat( addn_rel, 1, 3 );
    else
        perturbations = (m.prismnodes(2:2:end,:) - m.prismnodes(1:2:end,:)) ...
            .* repmat( addn(:), 1, 3 );
    end
    m.prismnodes = m.prismnodes + ...
        reshape( repmat( perturbations', 2, 1 ), 3, [] )';
    m.globalProps.alwaysFlat = false;
    m.globalProps.twoD = false;
    m.globalProps.trinodesvalid = false;
    m = makeTRIvalid( m );
    if m.globalProps.rectifyverticals
        m = rectifyVerticals( m );
    end
    m = recalc3d( m );
    m.initialbendangle = m.currentbendangle;
end
