function v1 = renumberArray( v, ren )
%v1 = renumberArray( v, ren )
%   Replace every element x of v by ren(x).
%   Works for arrays of any number of dimensions.
    v1 = reshape( ren(v), size(v) );
end
