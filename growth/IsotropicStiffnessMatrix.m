function D = IsotropicStiffnessMatrix( K, nu, plastic )
%D = IsotropicStiffnessMatrix( K, nu, springy )
%   This computes the 6*6 stiffness
%   matrix for an isotropic material with bulk  modulus K and Poisson's
%   ratio nu. 
%
%   If nu is equal to 0.5, the result depends on whether plastic is true
%   (by default it is false).
%
%   If true, the matrix will be calculated in the same way as for nu < 0.5.
%   If false, it will be calculated according to a different method, that
%   corresponds to a different way of approaching the limit of nu=0.5. In
%   the latter case, K is taken to be Young's modulus for a springy and
%   incompressible material.
%
%   If K or nu are vectors of the same length N > 1, D is returned as a
%   6*6*N matrix.

    if nargin < 3
        plastic = false;
    end

    multiK = numel(K) > 1;
    multinu = numel(nu) > 1;
    if multiK
        if ~multinu
            nu = nu + zeros(size(K));
        end
    else
        if multinu
            K = K + zeros(size(nu));
        end
    end
    
    if plastic
        nu(:) = 0.5;
    end

    Z = 3*K./(1+nu);  % Common factor of lambda and mu.
    % Because we have no external forces, we could omit the constant factor
    % 3.  If K or nu are constant over the tissue, we can omit those as
    % well.  But we have not implemented this.
    
    singularNu = ~plastic & (nu >= 0.5);
    haveSingularNu = any(singularNu);
    
    if plastic || ~haveSingularNu
        a = Z.*(1-nu);
        b = Z.*nu;
        c = Z.*(1-2*nu)/2;
    elseif all(singularNu)
        a = Z;
        b = zeros(size(K));
        c = Z/2;
    else
        a = zeros(size(K));
        b = zeros(size(K));
        c = zeros(size(K));

        a(singularNu) = Z(singularNu);
        % b(singularNu) = 0;
        c(singularNu) = Z(singularNu)/2;

        a(~singularNu) = Z(~singularNu).*(1-nu(~singularNu));  % b + c + c  % In general, b + (d-1)*c, where d is the dimensionality of the space, here always 3.
        b(~singularNu) = Z(~singularNu).*nu(~singularNu);  % Lame's first parameter, usually called lambda.
        c(~singularNu) = Z(~singularNu).*(1-2*nu(~singularNu))/2;  % Shear modulus, Lame's second parameter, usually called mu.
    end
     
%     if springy
%         c = Z/2;
%         a = Z;
%         b = zeros(size(a));
%     else
%         b = Z.*nu;  % Lame's first parameter, usually called lambda.
%         c = Z.*(1-2*nu)/2;  % Shear modulus, Lame's second parameter, usually called mu.
%         a = Z.*(1-nu);  % b + c + c  % In general, b + (d-1)*c, where d is the dimensionality of the space, here always 3.
%     end
    if length(K)==1
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
end
