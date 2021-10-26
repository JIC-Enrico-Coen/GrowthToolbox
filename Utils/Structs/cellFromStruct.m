function c = cellFromStruct( s )
    f = fieldnames(s);
    v = struct2cell(s);
    c = cell(length(f),2);
    c(:,1) = f;
    c(:,2) = v;
    c = reshape( c', 1, [] );
end
