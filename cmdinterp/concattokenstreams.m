function ts2 = concattokenstreams( ts0, ts1 )
%ts2 = concattokenstreams( ts0, ts1 )
%   Create a token stream that reads first from ts0, and when that ends,
%   from ts1.

    if isempty(ts0)
        ts2 = ts1;
    elseif isempty(ts1)
        ts2 = ts0;
    else
        [ts0,end0] = atend( ts0 );
        [ts1,end1] = atend( ts1 );
        if end0
            ts2 = ts1;
        elseif end1
            ts2 = ts0;
        else
            ts2 = ts0;
            if isempty( ts2.stack )
                ts2.stack = ts1;
            else
                ts2.stack(end+1) = ts1;
            end
        end
    end
end
