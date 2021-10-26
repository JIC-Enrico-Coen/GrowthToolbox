function v = valueFromValueGrad( v1, v2, d, x )
%v = valueFromValueGrad( v1, v2, d, x )
%   Given a straight path of length d, suppose that some property of a
%   particle on the path varies linearly with distance, being v1 at the
%   start and v2 at the end. Calculate that property when it has travelled
%   a distance x.
%
%   v1, v2, d, and x can be single values or arrays of the same shape. v
%   will be an array of the same shape.

    v = v1 + (v2-v1).*(x./d);
end
