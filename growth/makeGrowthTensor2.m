function g = makeGrowthTensor2( majoraxis, majorgrowth, minorgrowth )
%t = makeGrowthTensor2( majoraxis, majorgrowth, minorgrowth )
%   Return a 2*2 matrix containing a growth tensor in two dimensions having
%   MAJORGROWTH along MAJORAXIS and MINORGROWTH perpendicular to that.

    g = [ [ majorgrowth, 0 ]; [ 0, minorgrowth ] ];
    vx = majoraxis/norm(majoraxis);
    vy = [ vx(2), -vx(1) ];
    rot = [ vx', vy' ];
    g = rot*g*rot';
end
