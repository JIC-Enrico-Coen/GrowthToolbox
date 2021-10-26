function n = mgenNameFromMgenMenu( h )
    n = getMenuSelectedLabel(h.displayedGrowthMenu);
    n = regexprep( n, '^\* *', '' );
end
