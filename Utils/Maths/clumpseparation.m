function cs = clumpseparation( v )
%cs = clumpseparation( v )
%   v is a vector which is expected to consist of a large number of values
%   that fall into clumps clustered around a smaller number of values.  The
%   spread of values within each clump is expected to be much smaller than
%   the difference of values between any two clumps.  This routine returns
%   the minimum separation found between any two members of different clumps.
%   v can be a row or column vector, or a matrix of any shape.
%
%   See also: clumpsize, clumpsepsize, clumplinear.

    cs = max(diffs(sort(diffs(sort(v(:))))));
end
