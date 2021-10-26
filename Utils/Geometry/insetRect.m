function r1 = insetRect( r, inset )
    if length(inset)==1
        inset = [inset inset inset inset];
    end
    r1 = [ r(1)+inset(1), r(2)+inset(2), r(3)-inset(1)-inset(3), r(4)-inset(2)-inset(4) ];
end
