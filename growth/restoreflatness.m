function [m,displacements] = restoreflatness( m, displacements )
    if isVolumetricMesh( m )
        return;
    end
    xaxis = m.globalInternalProps.flataxes(1);
    yaxis = m.globalInternalProps.flataxes(2);
    flataxis = m.globalInternalProps.flataxes(3);
    numpnodes = size( m.prismnodes, 1 );
    m.nodes = (m.prismnodes( 1:2:(numpnodes-1), : ) + m.prismnodes( 2:2:numpnodes, : ))/2;
    m.nodes(:,flataxis) = 0;
    m.prismnodes( 1:2:(numpnodes-1), [xaxis yaxis] ) = m.nodes(:,[xaxis yaxis]);
    m.prismnodes( 2:2:numpnodes, [xaxis yaxis] ) = m.nodes(:,[xaxis yaxis]);
    if strcmp( m.globalProps.thicknessMode, 'scaled' )
        m.prismnodes( 1:2:(numpnodes-1), flataxis ) = -m.globalDynamicProps.thicknessAbsolute/2;
        m.prismnodes( 2:2:numpnodes, flataxis ) = m.globalDynamicProps.thicknessAbsolute/2;
    else
        verticals = m.prismnodes( 2:2:numpnodes, flataxis ) - m.prismnodes( 1:2:(numpnodes-1), flataxis );
        halfheights = verticals/2; % sqrt( sum( verticals .* verticals, 2 ) )/2;
        m.prismnodes( 1:2:(numpnodes-1), flataxis ) = -halfheights;
        m.prismnodes( 2:2:numpnodes, flataxis ) = halfheights;
    end
    m.globalProps.trinodesvalid = true;
    m.globalProps.prismnodesvalid = true;
    if (nargin > 1) && (nargout > 1)
        displacements(:,flataxis) = 0;
    end
    m = makeAreasAndNormals( m );
end
