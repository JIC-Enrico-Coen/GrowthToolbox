function errs = checkUniqueRows( a )
    a = sort(a,2);
    [a,perm] = sortrows(a);
    nrows = size(a,1);
    da = a(2:nrows,:) == a(1:(nrows-1),:);
    errs = find(all(da,2));
    errs = unique( reshape( [errs'; errs'+1], 1, [] ) );
    errs = perm(errs);
end
