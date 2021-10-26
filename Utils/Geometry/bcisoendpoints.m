function isoendpoints = bcisoendpoints( v, bc )
%pts = bcisoendpoints( v, bc )
%   Given v, a vector of the three values of some scalar at the vertexes of
%   a triangle, and bc, the bcs of a point in the triangle.
%   Consider v as defining a linear function on the triangle.
%   Compute the bcs of the intersection of the isoline of this function
%   through the point bc with the three sides of the triangle.

% We must find bcx such that
%     [ 1  0  0  ]         [ bc(1) ]
%     [ 1  1  1  ] * bcx = [   0   ]
%     [ v1 v2 v3 ]         [   0   ]
% and similarly for bcy and bcz.  The result is [ bcx, bcy, bcz ];

    a = v(1);
    b = v(2);
    c = v(3);
    cb = c-b;
    ac = a-c;
    ba = b-a;
    x = bc(1);
    y = bc(2);
    z = bc(3);
    
    isoendpoints = ...
        [ [ 0; y-x*ac/cb; z-x*ba/cb ], ...
          [ x-y*cb/ac; 0; z-x*ba/ac ], ...
          [ x-z*cb/ba; y-z*ac/ba; 0 ] ];
end
