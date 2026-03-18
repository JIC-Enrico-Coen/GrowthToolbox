function b = unionBbox( b1, b2 )
    if isempty(b1)
        b = b2;
    elseif isempty(b2)
        b = b1;
    else
        sz = size(b1);
        b1 = reshape( b1, 2, [] );
        b2 = reshape( b2, 2, [] );
        b = [ min( b1(1,:), b2(1,:) );
              max( b1(2,:), b2(2,:) ) ];
        b = reshape(b, sz );
    end
end

