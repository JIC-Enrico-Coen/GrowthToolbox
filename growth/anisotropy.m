function a = anisotropy( pp )
%a = anisotropy( pp )
%   Calculate the anisotropy from parallel and perpendicular growth.
%   This is zero when both are zero, otherwise (par-perp)/(par+perp).

    g = sum(pp,2);
    ai = find(g ~= 0);
    a = pp(:,1)-pp(:,2);
    a(ai) = a(ai) ./ g(ai);
end
