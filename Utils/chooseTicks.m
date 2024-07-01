function ticks = chooseTicks( values, includezero )
    maxv = max(values);
    minv = min(values);
    if includezero
        maxv = max( maxv, 0 );
        minv = min( minv, 0 );
    end
    
    % If both maxv and minv have the same sign, then I need to find the
    % roundest number between them, offset them accordingly, then add the
    % offset back in.
    rv = roundestBetween( minv, maxv );
    if rv ~= 0
        minv = minv - rv;
        maxv = maxv - rv;
    end
    
    % Extend the range to a nice value.
    
    [maxa,maxticks] = extendToTickValue( maxv );
    [mina,minticks] = extendToTickValue( minv );
    
    maxticks = maxticks( maxticks >= mina );
    minticks = minticks( minticks <= maxa );
    if (maxticks(1) > 0) || ((length(minticks)==1) && (minticks(1)==0))
        ticks = maxticks;
    elseif (minticks(end) < 0) || ((length(maxticks)==1) && (maxticks(1)==0))
        ticks = minticks;
    else
        maxdelta = maxticks(2)-maxticks(1);
        mindelta = minticks(2)-minticks(1);
        if maxdelta > mindelta
            minticks = 0:-maxdelta:mina;
            if minticks(end) > mina
                minticks(end+1) = minticks(end)-maxdelta;
            end
            minticks = minticks(end:-1:1);
        elseif mindelta > maxdelta
            maxticks = 0:mindelta:maxa;
            if maxticks(end) > mina
                maxticks(end+1) = maxticks(end)+mindelta;
            end
        end
        ticks = [ minticks(1:end-1), maxticks ];
    end
    if rv ~= 0
        ticks = ticks + rv;
    end
end


function [v,ticks] = extendToTickValue( v )
    if v==0
        ticks = 0;
        return;
    end
    sv = sign(v);
    if v<0
        v = -v;
    end
    
    upper10 = ceil( log10( v ) );
    v1 = v/(10^(upper10-1));
    unit = floor( v1 );
    tenths = ceil( (v1-unit)*10 );
    
    v = unit+tenths/10;
    
    maxticks = 5;
    ticks = 0:v;
    if ticks(end) < ceil(v)
        ticks(end+1) = ticks(end) + 1;
    end
    if length(ticks) > maxticks+1
        decimation = ceil( unit/maxticks );
        ticks = 0:decimation:unit;
        if ticks(end) < ceil(v)
            ticks(end+1) = ticks(end) + decimation;
        end
    end
    
    scale = sv * 10^(upper10-1);
    
    ticks = ticks * scale;
    if sv==-1
        ticks = ticks(end:-1:1);
    end
    v = v * scale ;
end