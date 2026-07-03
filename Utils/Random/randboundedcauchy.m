function r = randboundedcauchy( varargin )
%r = randboundedcauchy( sz, name, value, name, value, ... )
%r = randboundedcauchy( sz1, sz2, ..., name, value, name, value, ... )
%r = randboundedcauchy( ..., type, name, value, name, value, ... )
%
%   The initial numerical arguments specify the size of the output, and are
%   optionally followed by a floating point type, either 'single' or
%   'double' (the default).
%
%   The options allow for translating and scaling the distribution, and
%   generating values constrained to lie in a given range.
%
%   Options:
%
%   mode:   The mode of the unbounded distribution. Default 0.
%
%   spread: The spread parameter. Default 1. This is the semi-interquartile
%       range of the unbounded distribution.
%
%   min:    The minimum allowed value. Default -Inf.
%
%   max:    The maximum allowed value. Default Inf.
%
%   min and max are understood relative to the Cauchy distribution as
%   scaled and translated by the mode and spread options. To pass a value v
%   relative to the standard Cauchy distribution, use v*spread + mode. v is
%   in this case a desired multiple of the SIQ relative to the mode.
%
%   MIN can validly be greater than MAX. Values will still be generated
%   within those bounds. If either is NaN all the results will be NaN.
%
%   MIN and MAX do not truncate values outside the range to the endpoints.
%   Instead, they generate values conditional upon them happening to lie
%   within the specified bounds. Thus relative frequencies within the
%   interval are the same as for the unbounded distribution.

    classname = 'double';
    options = {};
    curarg = 0;
    while curarg < nargin
        curarg = curarg+1;
        a = varargin{curarg};
        if isnumeric( a )
            % Nothing.
        elseif strcmp(a,'double') || strcmp(a,'single')
            classname = a;
            options = varargin( (curarg+1):end );
            break;
        else
            options = varargin( curarg:end );
            break
        end
    end
    sz = cell2mat( varargin( 1:(curarg-1) ) );
    sz(1,(length(sz)+1):2) = 1;
    
    
    r = [];
    [s,ok] = safemakestruct( mfilename(), options );
    if ~ok
        return;
    end
    setGlobals();
    s = defaultfields( s, 'mode', 0, 'spread', 1, 'min', -Inf, 'max', Inf );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'mode', 'spread', 'min' , 'max' );
    if ~ok
        return;
    end
    
    s.min = (s.min - s.mode)/s.spread;
    s.max = (s.max - s.mode)/s.spread;
    
    ang_lo = atan( s.min );
    ang_hi = atan( s.max );
    unif_rand = rand(sz);
    ang_rand = ang_lo + (ang_hi-ang_lo) * unif_rand;
    r = tan(ang_rand);
    r = r * s.spread + s.mode;
    r = cast(r,classname);
    xxxx = 1;
end
