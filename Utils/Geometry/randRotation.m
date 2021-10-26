function [r,ea] = randRotation()
%r = randRotation()
%   Generate a random rotation matrix in 3 dimensions.

    phi = asin(2*rand(1)-1);
    theta = rand(1)*pi*2;
    chi = rand(1)*pi*2;
    ea = [chi, phi, theta];
    r = eulerRotation( ea, 'XYZ' );
end
