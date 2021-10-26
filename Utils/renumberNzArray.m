function v1 = renumberNzArray( v, ren )
%v1 = renumberNzArray( v, ren )
%   Replace every positive element x of v by ren(x).
%   Works for arrays of any number of dimensions.

    vnz = v > 0;
    v1 = v;
    v1(vnz) = ren(v1(vnz));
end
