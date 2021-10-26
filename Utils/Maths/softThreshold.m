function v = softThreshold( v, threshold, halfwidth )
%v = softThreshold( v, threshold, halfwidth )
%   Multiply the values v by a function that smoothly proceeds from 0 to 1
%   (if halfwidth is positive) or 1 to 0 (if negative). If halfwidth is
%   zero, no change is made to v.

    if halfwidth==0
        rerturn;
    end
    
    ut = threshold + halfwidth;
    lt = threshold - halfwidth;
    upperPart = (v < ut) & (v >= threshold);
    lowerPart = (v > lt) & (v < threshold);
    v(upperPart) = upperCurve( v(upperPart), threshold, ut );
    v(lowerPart) = lowerCurve( v(lowerPart), lt, threshold );
end

function v = upperCurve( v, mt, ut )
    v = v .* (1 - (v-ut).^2/(2*(mt-ut)^2));
end

function v = lowerCurve( v, lt, mt )
    v = v .* (v-lt).^2/(2*(mt-lt)^2);
end
