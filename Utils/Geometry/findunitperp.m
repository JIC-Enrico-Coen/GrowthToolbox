function w = findunitperp( v )
%w = findunitperp( v )
%   Find a 3-element unit vector perpendicular to the 3-element unit vector v.

    w = findperp(v);
    for i=1:size(w,1)
        w(i,:) = w(i,:)/norm(w(i,:));
    end
end
