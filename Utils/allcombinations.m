function c = allcombinations( nn, fastest )
%c = allcombinations( nn, fastest )
%   Given a list of non-negative integers NN, generate an array of size
%   prod(NN(:)) x N containing every list of possible subscript sets into
%   an array of size NN.
%
%   FASTEST, if supplied, is either 'last' (the default) or 'first'. This
%   specifies which subscript of NN will vary fastest. For example,
%   
%   allcombinations([2 3],'first')
%
%      1     1
%      2     1
%      1     2
%      2     2
%      1     3
%   
%   allcombinations([2 3],'last') or allcombinations([2 3])
%
%      1     1
%      1     2
%      1     3
%      2     1
%      2     2
%      2     3


    n = numel(nn);
    c = zeros( prod(nn(:)), n );
    if nargin < 2
        fastestlast = true;
    else
        switch lower(fastest)
            case 'last'
                fastestlast = true;
            case 'first'
                fastestlast = false;
            otherwise
                error( 'Invalid value ''%s'' for FASTEST parameter.', fastest );
        end
    end
    for i=1:n
        if fastestlast
            c1 = repmat( (1:nn(i)), prod(nn((i+1):n)), prod(nn(1:(i-1))) );
        else
            c1 = repmat( (1:nn(i)), prod(nn(1:(i-1))), prod(nn((i+1):n)) );
        end
        c(:,i) = c1(:);
    end
end
