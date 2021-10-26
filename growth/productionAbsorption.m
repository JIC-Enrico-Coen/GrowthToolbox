function v1 = productionAbsorption( v, p, a, dt )
%v1 = productionAbsorption( v, p, a, dt )
%   Given a substance with current value v, being produced at a rate p and
%   decaying at a rate a, calculate its value after a time interval dt.
%   p is assumed to have the same shape as v. a is either the same shape or
%   a single value. dt is a single value, and not assumed to be small.

    if numel(a)==1
        % There is a single value of absorption to be used everywhere.
        if a==0
            v1 = v + p*dt;
        else
            abs = exp( -a*dt );
            v1 = v*abs + p*(1-abs)/a;
        end
    else
        % There is a value of absorption per value of v.
        abs = exp( -a*dt );
        pa = (1-abs)./a;
        % Wherever a is zero, (1-abs)/a calculates as NaN, so at
        % those places we must use a different formula, accurate
        % for small values of a: dt*(1 - a*dt/2 + ((a*dt)^2)/6).
        smallabs = a < 1e-5;
        if any(smallabs)
            % The relative error of this approximation is no larger than
            % about 2e-11.
            pa(smallabs) = dt*(1 - a(smallabs)*(dt/2) + (a(smallabs).^2)*(dt/6));
        end
        v1 = v.*abs + p.*pa;
    end
end
