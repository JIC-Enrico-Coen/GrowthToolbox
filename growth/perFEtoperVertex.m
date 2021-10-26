function perFEvertex = perFEtoperVertex( m, perFE, method )
%perVx = perFEtoperVertex( m, perFE, method )
%   Deprecated, retained for backwards compatibility.
%
%   See also: FEToFEvertex

    if nargin < 3
        method = 'mid';
    end
    
    perFEvertex = FEToFEvertex( m, perFE, method );
end
