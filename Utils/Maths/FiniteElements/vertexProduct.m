function v = vertexProduct( v1, v2 )
    if isempty(v2)
        v = v1;
    elseif isempty(v1)
        v = v2;
    else
        v = zeros( size(v1,1)*size(v2,1), size(v1,2)+size(v2,2) );
        for i=1:size(v2,1)
            vrange1 = (i-1)*size(v1,1) + (1:size(v1,1));
            v( vrange1, : ) = [ v1, repmat( v2(i,:), size(v1,1), 1 ) ];
        end
    end
end
