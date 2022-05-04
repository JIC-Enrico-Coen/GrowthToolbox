function [dividepoint1,divideperp1] = splitPolyMinDiam( cellcoords, cellNormal, biosplitnoise )
    % Split along the minimum diameter.
    [dividepoint1,divideperp1,distance] = polysplitdiameter( cellcoords );
    w = cross(divideperp1,cellNormal);
    if biosplitnoise > 0
        p = randInCircle2( biosplitnoise*distance );
        dividepoint1 = dividepoint1 + p(1)*divideperp1 + p(2)*w;
    end
    divideperp1 = w;
end

