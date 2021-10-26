function m = meshFlatStrain( m, scale )
%m = meshFlatStrain( m, scale )
%   Set the residual strain to be the strain the mesh must have, for its
%   relaxed state to be flat.  If scale is supplied, the strain is
%   multiplied by that amount.

    if nargin < 2
        scale = 1;
    end

    if m.globalProps.rectifyverticals
        m = rectifyVerticals( m );
    end
    m = computeGNGlobal( m );
    numCells = size(m.tricellvxs,1);
    MAXFLATSTRAIN = 0.1;
    maxallrs = 0;
    for ci=1:numCells
        trivxs = m.tricellvxs(ci,:);
        prismvxs = [ trivxs*2-1, trivxs*2 ];
        cellvxCoords = m.prismnodes( prismvxs, : );
        d = cellFlatDisplacements( cellvxCoords, m.unitcellnormals(ci,:) );
        m.celldata(ci).eps0gauss = zeros( 6, 6 );
        m.celldata(ci) = computeDisplacementStrains( m.celldata(ci), d );
        m.celldata(ci).residualStrain = m.celldata(ci).displacementStrain * scale;
        maxrs = max( abs(m.celldata(ci).residualStrain(:)) );
        if maxrs > 100000
          % x = 1; % Uncomment this command to allow a breakpoint to be set here.
        end
        if false && (maxrs > MAXFLATSTRAIN)
            strainScale = MAXFLATSTRAIN/maxrs;
            m.celldata(ci).residualStrain = strainScale * m.celldata(ci).residualStrain;
        end
        maxallrs = max( maxrs, maxallrs );
        m.celldata(ci).displacementStrain = zeros( 6, 6 );
    end
  % meshFlatStrain_maxallrs = maxallrs
    if true && (maxallrs > MAXFLATSTRAIN)
        strainScale = MAXFLATSTRAIN/maxallrs;
        for ci=1:numCells
            m.celldata(ci).residualStrain = strainScale * m.celldata(ci).residualStrain;
        end
    end
end
