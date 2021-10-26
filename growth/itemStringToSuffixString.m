function ts = itemStringToSuffixString( is, n )
    t = regexp( is, '^([0-9]*)$', 'tokens' );
    if ~isempty(t)
        ts = t{1}{1};
        if length(ts) < n
            ts = [ repmat('0',1,n-length(ts)), ts ];
        end
        return;
    end
    
    t = regexp( is, '^([0-9]*)\.([0-9]*)$', 'tokens' );
    if length(t) < 1
        ts = repmat('9',1,n);
        return;
    end
    
    t = t{1};
    if length(t) < 2
        ts = repmat('9',1,n);
        return;
    end

    ts1 = t{1};
    ts2 = t{2};
    if length(ts1) < n
        ts1 = [ repmat('0',1,n-length(ts1)), ts1 ];
    end
    ts = [ ts1, 'd', ts2 ];
end
