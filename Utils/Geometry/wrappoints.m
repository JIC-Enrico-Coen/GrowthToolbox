function v = wrappoints( v, r )
%v = wrappoints( v, r )
%  Wrap the set of points around a cylinder whose axis is the z-axis, with
%  radius r.
    x = v(:,1)/r;
    rs = r + v(:,3);
    v = [ rs.*cos(x), rs.*sin(x), v(:,2) ];
end
