function gt = uniaxialGrowthTensor( direction, growthrate )
%gt = uniaxialGrowthTensor( direction )
%gt = uniaxialGrowthTensor( direction, growthrate )
%   Construct a growth tensor in 3x3 matrix form for growth in a given
%   direction at a given rate.  If growthrate is omitted, it is taken to be
%   the length of the direction vector. If direction is the zero vector,
%   a zero growth tendor will be returned, regardless of growth rate.
%
%   If direction is N*3 and growthrate, if supplied, is N*1, then gt will
%   be the sum of all the uniaxial tensors for corresponding rows of
%   direction and growthrate.

    absd = sqrt(sum(direction.^2,2));
    if nargin < 1
        growthrate = absd;
    else
        growthrate(absd==0) = 0;
    end

    gt = zeros(3,3);
    for i=1:size(direction,1)
        if growthrate(i) ~= 0
            d = direction(i,:)/absd(i);
            gt = gt + (growthrate(i)*d')*d;
        end
    end
end
