function [m,displacements] = setThickness( m, thicknesses )
    if nargin==1
        m.globalDynamicProps.thicknessAbsolute = ...
            m.globalProps.thicknessRelative * ...
                m.globalDynamicProps.currentArea^(m.globalProps.thicknessArea/2);
    else
        numpnodes = size( m.prismnodes, 1 );
        delta = m.prismnodes( 1:2:(numpnodes-1), : ) - ...
            m.prismnodes( 2:2:numpnodes, : );
        oldthicknesses = sqrt( sum( delta.^2, 2 ) );
        relativeDisps = thicknesses./oldthicknesses - 1;
        displacementsB = delta .* repmat( relativeDisps/2, 1, size(delta,2) );
        displacements = reshape( [ displacementsB'; -displacementsB' ], 3, [] )';
        m.prismnodes = m.prismnodes + displacements;
    end
end
