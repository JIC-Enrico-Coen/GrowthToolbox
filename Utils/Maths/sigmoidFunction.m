function sf = sigmoidFunction( type )
%sf = sigmoidFunction( type )
%   Return one of a set of canned interpolation functions.
%   If a function handle is given, that is returned.
%   If the name is not recognised, the name is returned. Test for this with
%   ischar(sf).
%
%   Each of these functions should be an increasing function from
%   [-1 1] onto [-1 1]. Everything less than -1, including -Inf,
%   should be mapped to -1, and similarly for values greater than 1.
%   It may be presumed to never be given the argument NaN.
%
%   'linear', 'cubic' and 'sin' are continuous with all continuous
%       derivatives.
%
%   'quad' is continuous with continuous first derivative and a second
%       derivative continuous except at 0.
%
%   'circ' is continuous. Its first derivative is infinite at 0, and its
%       higher derivatives are discontinuous at 0.
%
%   The first derivatives of these at 0 are respectively 1, 1.5,
%   pi/2 = 1.57, 2, and Inf.

    if isa(type,'function_handle')
        sf = type;
    else
        switch type
            case 'linear'
                sf = @lininterp;
            case 'quad'
                sf = @quadinterp;
            case 'cubic'
                sf = @(x) x*(3/2) - (x.^3)/2;
            case 'sin'
                sf = @(x) sin(x*(pi/2));
            case 'circ'
                sf = @circinterp;
            case 'expcirc'
                sf = @expcircinterp;
            otherwise
                % Interpolation function not recognised. Return the name
                % that was supplied.
                sf = type;
                return;
        end
    end
end

function v = lininterp( x )
    v = x;
end

function v = quadinterp( x )
    v(x<0) = x(x<0).*(x(x<0)+2);
    v(x>0) = x(x>0).*(2-x(x>0));
end

function v = circinterp( x )
    v(x<0) = -sqrt(1-(x(x<0)+1).^2);
    v(x>0) = sqrt(1-(x(x>0)-1).^2);
end

function v = expcircinterp( x )
    v = x .* exp( -1./(1-x.^2) );
end

