function a = inertiaToAxes( moments, mode, value )
%a = inertiaToAxes( moments )
%   Given the principal moments of inertia of an ellipsoid of unit uniform
%   density, calculate the semi-axes.
%
%   Not all triples of values are the principal moments of any real body.
%   If invalid moments are given, some of the resulting axes may have
%   imaginary components. Only the real parts will be returned.
%
%a = inertiaToAxes( moments, 'density', d )
%   Calculate the semi-axes, given that uniform density.
%
%a = inertiaToAxes( moments, 'sectionaldensity', d )
%   Like the previous, but if any axes are zero, the density is taken to be
%   per area, per length, or per point.
%
%a = inertiaToAxes( moments, 'mass', m )
%   Calculate the semi-axes, given the total mass.
%
%a = inertiaToAxes( moments, 'ratio' )
%   Calculate the semi-axes, up to an arbitrary constant factor. This is a
%   much simpler computation, suitable when only the ratio of the axes is
%   important. It is also guaranteed to produce a real answer even when the
%   complete calculation would yield imaginary components.
%
%   moments may be a row or column vector, and a will have the same shape.
%
%   This procedure is an inverse to axesToInertia (up to rounding error),
%   except in edge cases where inertiaToAxes is not defined.
%
%   SEE ALSO: axesToInertia

    if (nargin > 1) && strcmpi( mode, 'ratio' )
        % [ -1 1 1; 1 -1 1; 1 1 -1 ]/2 is the inverse of the matrix
        % [0 1 1;1 0 1;1 1 0] used in axesToInertia.
        % The real() operation is to ensure that rounding errors or invalid
        % moments do not result in imaginary semi-axis lengths.
        a = real( sqrt( [ -1 1 1; 1 -1 1; 1 1 -1 ] * (moments(:) / 2) ) );
    else
        haveDensity = true;
        density = 1;
        sectionaldensity = false;
        if nargin >= 3
            switch mode
                case 'density'
                    density = value;
                case 'sectionaldensity'
                    density = value;
                    sectionaldensity = true;
                case 'mass'
                    mass = value;
                    haveDensity = false;
            end
        end
        if haveDensity
            abc_a2_b2_c2 = (5/(2*density)) * [ -1 1 1; 1 -1 1; 1 1 -1 ] * moments(:); % abc[a^2 b^2 c^2]
            if sectionaldensity
                densityaxes = abc_a2_b2_c2 > 0;
            else
                densityaxes = true(3,1);
            end
            switch sum( densityaxes )
                case 0
                    volfactor = 1;
                case 1
                    volfactor = 2;
                case 2
                    volfactor = pi;
                case 3
                    volfactor = 4*pi/3;
            end
            abc_a2_b2_c2 = abc_a2_b2_c2/volfactor;
            abc5 = prod(abc_a2_b2_c2(densityaxes));
            abc = abc5^0.2;
            a = real( sqrt(abc_a2_b2_c2/abc) );
        else
            a2_b2_c2 = (5/(2*mass)) * [ -1 1 1; 1 -1 1; 1 1 -1 ] * moments(:); % [a^2 b^2 c^2]
            a = real( sqrt(a2_b2_c2) );
        end
    end
    
    a = reshape( a, size(moments) );
end