function b = unionBbox( b1, b2 )
    if isempty(b1)
        b = b2;
    elseif isempty(b2)
        b = b1;
    else
        b = [ min( b1(1,:), b2(1,:) );
              max( b1(2,:), b2(2,:) ) ];
    end
end

