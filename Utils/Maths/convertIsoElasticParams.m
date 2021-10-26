function s = convertIsoElasticParams( p1, v1, p2, v2 )
%s = convertIsoElasticParams( p1, v1, p2, v2 )
%   Given any two of the six standard elastic parameters of a 3-dimensional
%   isotropic material, return a struct containing all of them:
%       s.bulk      bulk modulus
%       s.young     Young's modulus
%       s.lame1     Lame's first parameter
%       s.shear     shear modulus
%       s.poisson   Poisson's ratio (also called Lame's second parameter)
%       s.pwave     P-wave modulus
%   p1 and p2 are any two distinct field names from the above list, and v1
%   and v2 are their values.
%   For certain pairs (young and either lame1 or pwave), the computation
%   requires the solution of a quadratic equation, and hence there are two
%   solutions.  Only one solution will be returned, and when possible, it
%   will be a physically realistic one (i.e. all properties except
%   s.poisson will be non-negative, and s.poisson will be in the range
%   -1...0.5).  Some of the calculations will be singular when s.poisson is
%   equal to -1 or 0.5.
%
%   If the arguments p1 and p2 are equal, or either is unrecognised, an
%   empty result is returned.
%
%   v1 and v2 can be either single values or larger arrays.  If they are
%   both larger arrays they must have the same shape.  In this case, all
%   fields of the result will have that shape.

    s = struct( 'bulk', 0, 'young', 1, 'lame1', 2, 'shear', 3, 'poisson', 4, 'pwave', 5 );
    try
        if s.(p1)==s.(p2)
            % The two field names are identical.
            s = [];
            return;
        end
    catch e %#ok<NASGU>
        % At least one of the fields does not exist.
        s = [];
        return;
    end
    if s.(p1) < s.(p2)
        s = struct( p1, v1, p2, v2 );
    else
        s = struct( p2, v2, p1, v1 );
        temp = p2;
        p2 = p1;
        p1 = temp;
        v1 = s.(p1);
        v2 = s.(p2);
    end
    
    if numel(v1)==1
        v1 = v1 + zeros(size(v2));
    elseif numel(v2)==1
        v2 = v2 + zeros(size(v1));
    else
        sz1 = size(v1);
        sz2 = size(v2);
        if (length(sz1) ~= length(sz2)) || any(sz1 ~= sz2)
            s = [];
            return;
        end
    end

    switch p1
        case 'bulk'
            switch p2
                case 'young'
                    d = 9*v1-v2;
                    s.lame1 = 3*v1.*(3*v1-v2)./d;
                    s.shear = 3*v1*v2/d;
                    s.poisson = (3*v1-v2)./(6*v1);
                    s.pwave = 3*v1.*(3*v1+v2)./d;
                case 'lame1'
                    d = 3*v1-v2;
                    s.young = 9*v1.*(v1-v2)./d;
                    s.shear = 3*(v1-v2)/2;
                    s.poisson = v2/d;
                    s.pwave = 3*v1-2*v2;
                case 'shear'
                    d = 3*v1+v2;
                    s.poisson = (3*v1-2*v2)./(2*d);
                    s.young = 9*v1.*v2./d;
                    s.pwave = v1 + 4*v2/3;
                    s.lame1 = v1 - 2*v2/3;
                case 'poisson'
                    d = 1+v2;
                    s.young = 3*v1.*(1-2*v2);
                    s.lame1 = 3*v1.*v2./d;
                    s.shear = 3*v1.*(1-2*v2)./(2*d);
                    s.pwave = 3*v1.*(1-v2)./d;
                case 'pwave'
                    d = 3*v1+v2;
                    s.young = 9*v1.*(v2-v1)./d;
                    s.lame1 = (3*v1-v2)/2;
                    s.shear = 3*(v2-v1)/4;
                    s.poisson = (3*v1-v2)./d;
            end
        case 'young'
            switch p2
                case 'lame1'
                    r = v1./v2;
                    b = (1 + r)/2;
                    sq = sqrt(b.*b+2);
                    s.poisson = (-b + sq)/2;
                    useOtherSolution = (poisson1 > 0.5) | (poisson1 < -1);
                    s.poisson(useOtherSolution) = (-b(useOtherSolution) - sq(useOtherSolution))/2;
                    s = convertIsoElasticParams( 'young', s.young, 'poisson', s.poisson );
                case 'shear'
                    d = 3*v2-v1;
                    s.bulk = v1.*v2./(3*d);
                    s.lame1 = v2.*(v1-2*v2)./d;
                    s.poisson = v1./(2*v2) - 1;
                    s.pwave = v2.*(4*v2-v1)./d;
                case 'poisson'
                    d = (1+v2).*(1-2*v2);
                    s.bulk = v1./(3*(1-2*v2));
                    s.lame1 = v1.*v2./d;
                    s.shear = v1./(2*(1+v2));
                    s.pwave = v1.*(1-v2)./d;
                case 'pwave'
                    b = v1/3 - v2;
                    c = v1.*v2/9;
                    sdisc = sqrt(b.*b-4*c);
                    s.bulk = (-b + sdisc)/2;
                    useOtherSolution = b <= -2; % This is the wrong condition -- dimensionally inconsistent.
                    s.bulk(useOtherSolution) = (-b(useOtherSolution) - sdisc(useOtherSolution))/2;
%                     if b > -2
%                         s.bulk = (-b + sqrt(disc))/2;
%                     else
%                         s.bulk = (-b - sqrt(disc))/2;
%                     end
                    s = convertIsoElasticParams( 'bulk', s.bulk, 'young', s.young );
            end
        case 'lame1'
             switch p2
                case 'shear'
                    s.bulk = v1 + 2*v2/3;
                    s.young = v2.*(3*v1+2*v2)./(v1+v2);
                    s.poisson = v1./(2*(v1+v2));
                    s.pwave = v1 + 2*v2;
                case 'poisson'
                    s.bulk = v1.*(1+v2)./(3*v2);
                    s.young = v1.*(1+v2).*(1-2*v2)./v2;
                    s.shear = v1.*(1-2*v2)./(2*v2);
                    s.pwave = v1.*(1-v2)./v2;
                case 'pwave'
                    s.bulk = (v2+2*v1)/3;
                    s.young = (v2-v1).*(2*v1+v2)./(v1+v2);
                    s.shear = (v2-v1)/2;
                    s.poisson = v1./(v1+v2);
             end
       case 'shear'
            switch p2
                case 'poisson'
                    s.bulk = 2*v1.*(1+v2)./(3*(1-2*v2));
                    s.young = 2*v1.*(1+v2);
                    s.lame1 = 2*v1.*v2./(1-2*v2);
                    s.pwave = 2*v1.*(1-v2)./(1-2*v2);
                case 'pwave'
                    s.bulk = v2 - 4*v1/3;
                    s.young = v1*(3*v2-4*v1)/(v2-v1);
                    s.lame1 = v2 - 2*v1;
                    s.poisson = (v2-2*v1)/(2*(v2-v1));
            end
       case 'poisson'
            switch p2
                case 'pwave'
                    s.bulk = v2.*(1+v1)./(3*(1-v1));
                    s.young = v2.*(1+v1).*(1-2*v1)./(1-v1);
                    s.lame1 = v1.*v2./(1-v1);
                    s.shear = v2.*(1-2*v1)./(2*(1-v1));
            end
    end                    
end
