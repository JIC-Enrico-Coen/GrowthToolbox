function s1 = repeatString( s, n )
    s1 = char(reshape(s'*ones(1,n),[],1)');
end
