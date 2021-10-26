function v = widenValues( v, scaling )
%v = widenValues( v, scaling )
%   Scale the elements of v about their average.

    mid = mean(v);
    v = scaling*(v - mid) + mid;
end
