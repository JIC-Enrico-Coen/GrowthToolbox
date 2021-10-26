function pp = pp_from_ga( ga )
    pp = [ ga(:,1).*(1+ga(:,2)), ga(:,1).*(1-ga(:,2)) ];
end
