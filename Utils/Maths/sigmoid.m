function [v,sigfunc] = sigmoid( x, xrange, vrange, type, test )
%[v,sigfunc] = sigmoid( x, xrange, vrange, type, test )
%   X is an array of values of any shape.
%   V will be the result of first clipping X to the range XRANGE(1) to
%   XRANGE(2), then mapping that smoothly to the interval from VRANGE(1) to
%   VRANGE(2). The endpoints of the ranges do not have to be in sorted
%   order, and the right thing will still be done if they are equal. They
%   must be finite.
%
%   The mapping is given by TYPE, which takes one of these values:
%
%   'linear'  Linear interpolation. This has a discontinuous first
%       derivative at the endpoints.
%
%   'quad'    Quadratic interpolation. This has a continuous first
%       derivative and discontinuous second derivative at the endpoints and
%       at the middle of the range.
%
%   'cubic'   Cubic interpolation. This has a continuous first
%       derivative and discontinuous second derivative at the endpoints.
%
%   'sin'     Sinusoid interpolation. This has a continuous first
%       derivative and discontinuous second derivative at the endpoints.
%
%   'circ'    Circular interpolation. The first derivative is infinite at
%       x=0, and its second derivative is discontinuous at -1, 0, and 1.
%       The graph looks like two quarter circles.
%
%   TYPE can also be a function handle, which will be used directly. This
%   function should take one argument and define a function
%   from [-1 1] to [-1 1]. It can assume that it will never be given
%   arguments outside that range, nor NaN values. It should accept an array
%   of any shape, map each of its elements, and return an array of the same
%   shape.
%
%   A handle to the function is returned in sigfunc.
%
%   If TEST is provided and true, a graph of the mapping is plotted in a
%   new window.

    if nargin < 5
        test = false;
    end
    
    % Choose the interpolation function.
    sigfunc = sigmoidFunction( type );
    if ischar(sigfunc)
        % The type was not recognised.
        v = x;
        return;
    end
    
    if length(vrange)==1
        % Everything must be mapped to vrange.
        v = vrange + zeros(size(x),class(x));
        return;
    end
    
    if length(xrange)==1
        vvals = [vrange(1), (vrange(1)+vrange(2))/2, vrange(2)];
        v = vvals( sign(x-xrange)+2 );
        return;
    end
    
    [xrange,p] = sort(xrange);
    vrange = vrange(p);
    
    xmin = xrange(1);
    xmax = xrange(2);
    xmid = (xmin+xmax)/2;
    vmin = vrange(1);
    vmax = vrange(2);
    
    x0 = x;
    
    % Rescale x to [-1 1].
    x = 2*(x - xmid)/(xmax-xmin);
    x(x<-1) = -1;
    x(x>1) = 1;
    
    % Generate v in the range [-1 1].
    v = sigfunc( x );
    v(isnan(x0)) = NaN;
    v(x<-1) = -1;
    v(x>1) = 1;
    
    % Shift and rescale v.
    v = (vmin+vmax)/2 + ((vmax-vmin)/2)*v;
    
    if test
        [~,ax] = getFigure();
        [x0s,p] = sort(x0(:));
        vs = v(p);
        plot( x0s, vs, '.-', 'Parent', ax );
    end
end

