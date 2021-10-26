function v = vertexVertexDiffuse( m, v, n, alph )
%v = vertexVertexDiffuse( m, v, n, alph )
%   v is an N*K array holding K values for each of the N vertexes of the mesh m.
%   Each value of v is replaced by a weighted average of itself and the values of
%   all its neighbours, n times over.  The default value of n is 1.
%
%   If a vertex has value v and k neighbours, and the sum of its
%   neighbours' values is v1, then the resulting value of the vertex is
%
%       (v + alph*v1)/(1+alph*k)
%
%   The default value of alph is 1.
%
%   This is not a physical model of diffusion.

    if nargin < 3
        n = 1;
    end
    
    if nargin < 4
        alph = 1;
    end
    
    for i=1:n
        [v1,n] = sumArray( m.edgeends, v( m.edgeends(:,[2 1]) ), size(v) );
        v = (v + alph*v1)./(1+alph*n);
    end
end
