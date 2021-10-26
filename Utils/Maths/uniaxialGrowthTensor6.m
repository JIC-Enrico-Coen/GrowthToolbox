function gt = uniaxialGrowthTensor6( direction, growthrate )
%gt = uniaxialGrowthTensor( direction, growthrate )
%   Construct a growth tensor in 6-vector form for growth in a given
%   direction at a given rate.  direction is assumed to be a unit vector.
%
%   If direction is N*3 and growthrate, if supplied, is N*1, then gt will
%   be the sum of all the uniaxial tensors for corresponding rows of
%   direction and growthrate.

    gt = zeros(1,6);
    for i=1:size(direction,1)
        d = direction(i,:);
        a = d(1);  b = d(2);  c = d(3);
        gt = gt + [d.^2 2*b*c 2*c*a 2*a*b];
    end
end
