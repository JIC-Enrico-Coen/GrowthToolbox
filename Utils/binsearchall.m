function i = binsearchall( vec, vals )
%i = binsearchall( vec, vals )
%   Apply binsearch to vec and every member of the array vals.
%   The result is a matrix the same shape as vals.

    i = reshape( binsearchupper( vec, reshape( vals, 1, [] ) ), size(vals) );
end