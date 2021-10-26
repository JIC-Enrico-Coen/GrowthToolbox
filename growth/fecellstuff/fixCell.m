function c = fixCell( c, isfixed )
    if nargin < 2
        c.fixed = 1 - c.fixed;
    else
        c.fixed = isfixed;
    end
end
   