function a = translatearray( a, v )
    for i=1:size(a,1)
        a(i,:) = a(i,:) + v;
    end
end
