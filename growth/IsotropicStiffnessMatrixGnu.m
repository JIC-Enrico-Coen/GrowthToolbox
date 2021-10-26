function D = IsotropicStiffnessMatrixGnu( G, nu )
%D = IsotropicStiffnessMatrixGnu(( G, nu )
%   Compute the 6*6 stiffness matrix for an isotropic material with shear
%   modulus G and Poisson's ratio nu, multiplied by 1-2*nu.  If G and nu
%   are vectors of the same length N > 1, D is returned as an 6*6*N matrix.

    denominator = 1-2*nu;
    lambda = 2*G*nu;  % Lame's first parameter
  % mu = lambda.*(1/(2*nu) - 1);
    mu = G*denominator;  % Shear modulus, Lame's second parameter.
    a = lambda + mu + mu;
    b = lambda;
    c = mu;
    if length(G)==1
        D = [ a b b 0 0 0;
              b a b 0 0 0;
              b b a 0 0 0;
              0 0 0 c 0 0;
              0 0 0 0 c 0;
              0 0 0 0 0 c ];
    else
        a = reshape(a,1,1,[]);
        b = reshape(b,1,1,[]);
        c = reshape(c,1,1,[]);
        z = zeros(size(c));
        D = [ 
                [ [ [a b b];[b a b];[b b a] ], zeros(3,3,length(K)) ];
                [ zeros(3,3,length(K)) [ [c z z];[z c z];[z z c] ] ]
            ];
    end
    D = D/denominator;
end
