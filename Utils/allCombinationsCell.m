function c = allCombinationsCell( varargin )
%c = allCombinationsCell( varargin )
%   The arguments are numeric arrays. Their shape is irrelevant, only the
%   number of elements in each matters.
%
%   c is set to a numeric array whose first dimension is equal in length to
%   the number of arguments, and whose second dimension is the product of
%   the numbers of elements in each of the arguments. The columns of c
%   consist of all possible ways to choose an element from each of the
%   argument arrays.

    if nargin==0
        c = [];
        return;
    end

    cc = varargin;
    c = cc{1};
    c = c(:)';
    lc = size(c,2);
    for i=2:length(cc)
        v = cc{i};
        vn = length(v);
        c1 = [ repmat( c, 1, vn );
               reshape( repmat( v(:)', lc, 1 ), 1, [] ) ];
        c = c1;
        lc = size(c,2);
    end
end

