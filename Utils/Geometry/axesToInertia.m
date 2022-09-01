function moments = axesToInertia( a, mode, value )
%moments = axesToInertia( a )
%   Given the semi-axes of an ellipsoid of unit uniform density, calculate
%   the principal moments of inertia.
%
%moments = axesToInertia( a, 'density', d )
%   Stipulate the uniform density of the ellipsoid.
%
%moments = axesToInertia( a, 'sectionaldensity', d )
%   Stipulate the uniform sectional density, with respect to the non-zero
%   axes.
%
%moments = axesToInertia( a, 'mass', m )
%   Stipulate the mass of the ellipsoid. This allows any of the semi-axes
%   to be zero and give a nonzero result.
%
%moments = axesToInertia( a, 'ratio' )
%   Calculate the moments, up to an arbitrary constant factor. This is a
%   much simpler computation, suitable when only the ratio of the moments
%   is important.
%
%   a may be a row or column vector, and moments will have the same shape.
%
%   This procedure is an inverse to inertiaToAxes (up to rounding error),
%   except in edge cases where inertiaToAxes is not defined.
%
%   SEE ALSO: inertiaToAxes

    if (nargin > 1) && strcmpi( mode, 'ratio' )
        moments = [0 1 1;1 0 1;1 1 0] * a(:).^2;
    else
        density = 1;
        densityaxes = true(3,1);
        haveDensity = true;
        if nargin==3
            switch mode
                case 'mass'
                    mass = value;
                    haveDensity = false;
                case 'density'
                    density = value;
                case 'sectionaldensity'
                    density = value;
                    densityaxes = a > 0;
            end
        end
        if haveDensity
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
            vol = prod(a(densityaxes)) * volfactor;
            mass = vol * density;
        end
        moments = (mass/5) * ([0 1 1;1 0 1;1 1 0] * a(:).^2);
    end
    
    moments = reshape( moments, size(a) );
end