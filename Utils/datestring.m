function s = datestring( c, timeonly )
    if nargin < 1
        c = clock;
        timeonly = false;
    elseif numel(c)==1
        timeonly = logical(c);
        c = clock();
    elseif nargin < 2
        timeonly = false;
    end
    if timeonly
        s = sprintf( '%02d:%02d:%02d', round(c(4:6)) );
    else
        s = sprintf( '%d/%02d/%02d %02d:%02d:%02d', round(c) );
    end
    if nargout < 1
        fwrite( 1, s );
    end
end