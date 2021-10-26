function vs = interp( keys, vals, xs )
%v = interp( keys, vals, x )
%   Look up x in keys (must be in ascending order) and return corresponding
%   value from vals, with piecewise linear interpolation.

    if length(vals) < length(keys)
        vals( (end+1):length(keys) ) = vals(end);
    end
    vs = zeros(size(xs));
    for xi=1:numel(xs)
        x = xs(xi);
        if x <= keys(1)
            vs(xi) = vals(1);
        else
            found = false;
            for i=2:length(keys)
                if x < keys(i)
                    a = keys(i)-x;
                    b = x - keys(i-1);
                    vs(xi) = (vals(i-1)*a + vals(i)*b)/(a+b);
                    found = true;
                    break;
                end
            end
            if ~found
                vs(xi) = vals(length(keys));
            end
        end
    end
end
