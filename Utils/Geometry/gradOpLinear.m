function [gol,gol1,gol2] = gradOpLinear( vxs )
%gol = gradOpLinear( vxs )
%   Given a matrix vxs whose three rows are the corners of a triangle,
%   determine a 9*9 matrix go such that for any 3*3-matrix v, representing a
%   velocity at each vertex of the triangle, we have
%   reshape(go,[],1) = go * reshape(v,[],1).

    go = gradT(vxs) * vxs;
%   g1t = goT * velT
%   g1t(i,j) = goT(i,k) velT(k,j)
%       = go(k,i) vel(j,k)
%   gtbig(p,q) = dep of g1t(p1,p2) on vel(q1,q2)
%   p   q   pi  pj  qj  qk  gtbig(p,q) = go(k,i)
%   1   1   1   1   1   1   go(1,1)
%   1   4   1   1   1   2   go(2,1)
%   1   7   1   1   1   3   go(2,1)
%   gtbig(1,[1 4 7]) = go(:,1)
%   2   1   2   1   1   1   go(1,2)
%   2   4   2   1   1   2   go(2,2)
%   2   7   2   1   1   3   go(3,2)
%   gtbig(2,[1 4 7]) = go(:,2)
%   gtbig(3,[1 4 7]) = go(:,3)
%   4   2   1   2   2   1   go(1,1)
%   4   5   1   2   2   2   go(2,1)
%   4   8   1   2   2   3   go(3,1)
%   gtbig(4,[2 5 8]) = go(:,1)
%   gtbig(5,[2 5 8]) = go(:,2)
%   gtbig(6,[2 5 8]) = go(:,3)
%   gtbig(7,[3 6 9]) = go(:,1)
%   gtbig(8,[3 6 9]) = go(:,2)
%   gtbig(9,[3 6 9]) = go(:,3)
    
%   g1 = vel * go
%   g1(i,j) = vel(i,k) go(k,j)
%   gbig(p,q) = dependency of g1(p1,p2) on vel(q1,q2)
%   p1==q1
%   p   q   pi  pj  qi  qk  gbig(p,q)
%   1   1   1   1   1   1   go(1,1)
%   1   4   1   1   1   2   go(2,1)
%   1   7   1   1   1   3   go(3,1)
%   gbig(1,[1 4 7]) = go(:,1)
%   2   2   2   1   2   1   go(1,1)
%   2   5   2   1   2   2   go(2,1)
%   gbig(2,[2 5 8]) = go(:,1)
%   gbig(3,[3 6 9]) = go(:,1)
%   4   1   1   2   1   1   go(1,2)
%   4   4   1   2   1   2   go(2,2)
%   gbig(4,[1 4 7]) = go(:,2)
%   gbig(5,[2 5 8]) = go(:,2)
%   gbig(6,[3 6 9]) = go(:,2)



%   2   2   2   1   2   1   go(1,1)
%   2   5   2   1   2   2   go(2,1)
%   2   8   2   1   2   3   go(3,1)
%   gbig(2,[2 5 8]) = go(:,1)
%   2   2   2   1   2   1   go(1,1)

%    go(i,j) = gt(i,k) vxs(k,j)
%    goT(i,j) = go(j,i) = gt(j,k) vxs(k,i)
%    gol2(p,q) = dependency of goT(pi,pj) on vxs(qi,qj)
%    p	q	pi  pj  qk  qi  k   gol2(p,q)
%    1   1   1   1   1   1   1   gt(1,1)
%    1   2   1   1   2   1   2   gt(1,2)
%    1   3   1   1   3   1   3   gt(1,3)
%    2   4   2   1   1   2   1   gt(1,1)
%    2   5   2   1   2   2   2   gt(1,2)
%    4   1   1   2   1   1   1   gt(2,1)
%    4   2   1   2   2   1   2   gt(2,2)    
    
    if 0
    gol1(1,[1 4 7]) = go(:,1);
    gol1(4,[1 4 7]) = go(:,2);
    gol1(7,[1 4 7]) = go(:,3);
    
    gol1(2,[2 5 8]) = go(:,1);
    gol1(5,[2 5 8]) = go(:,2);
    gol1(8,[2 5 8]) = go(:,3);
    
    gol1(3,[3 6 9]) = go(:,1);
    gol1(6,[3 6 9]) = go(:,2);
    gol1(9,[3 6 9]) = go(:,3);
    end

    
    if 0
    gol2(1,[1 4 7]) = go(:,1);
    gol2(2,[1 4 7]) = go(:,2);
    gol2(3,[1 4 7]) = go(:,3);
    
    gol2(4,[2 5 8]) = go(:,1);
    gol2(5,[2 5 8]) = go(:,2);
    gol2(6,[2 5 8]) = go(:,3);
    
    gol2(7,[3 6 9]) = go(:,1);
    gol2(8,[3 6 9]) = go(:,2);
    gol2(9,[3 6 9]) = go(:,3);
    end
    
    gol1([1 4 7],[1 4 7]) = go';
    gol1([2 5 8],[2 5 8]) = go';
    gol1([3 6 9],[3 6 9]) = go';

    gol2([1 2 3],[1 4 7]) = go';
    gol2([4 5 6],[2 5 8]) = go';
    gol2([7 8 9],[3 6 9]) = go';
    
    gol = (gol1+gol2)/2;
  % gol = gol( [1 5 9 8 7 4], : );
end
