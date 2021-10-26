function wasSet = testAndClear( guiFlag )
    wasSet = get( guiFlag, 'Value' ) ~= 0;
    if wasSet
        set( guiFlag, 'Value', 0 );
    end
end
