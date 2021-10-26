function C = IsotropicComplianceMatrix( K, nu, plastic )
%C = IsotropicComplianceMatrix( K, nu )
%   Compute the 6*6 compliance matrix for an isotropic material with bulk
%   modulus K and Poisson's ratio nu.

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

    singularNu = ~plastic & (nu >= 0.5);
    haveSingularNu = any(singularNu);
    
    lamu = 3*K./(1+nu);  % Common factor of lambda and mu.
    lambda = lamu.*nu;  % Lame's first parameter
    mu = lamu.*(1-2*nu)./2;  % Shear modulus, Lame's second parameter.
    z = 2*mu.*(3.*lambda+2*mu);
%     a = (2*lambda+2*mu)./z;
%     b = -lambda./z;
%     c = 1./mu;

    
    if plastic || ~haveSingularNu
        a = (2*lambda+2*mu)./z;
        b = -lambda./z;
        c = 1./mu;
    elseif all(singularNu)
        a = 0.5./K;
        b = zeros(size(K));
        c = 1./K;
    else
        a = zeros(size(K));
        b = zeros(size(K));
        c = zeros(size(K));

        a(singularNu) = 0.5./K(singularNu);
        % b(singularNu) = 0;
        c(singularNu) = 1./K(singularNu);

        a(~singularNu) = (2*lambda(~singularNu)+2*mu(~singularNu))./z(~singularNu);  % b + c + c  % In general, b + (d-1)*c, where d is the dimensionality of the space, here always 3.
        b(~singularNu) = -lambda(~singularNu)./z(~singularNu);  % Lame's first parameter, usually called lambda.
        c(~singularNu) = 1./mu(~singularNu);  % Shear modulus, Lame's second parameter, usually called mu.
    end
    
    if length(K)==1
        C = [ a b b 0 0 0;
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
        C = [ 
                [ [ [a b b];[b a b];[b b a] ], zeros(3,3,length(K)) ];
                [ zeros(3,3,length(K)) [ [c z z];[z c z];[z z c] ] ]
            ];
    end
end
