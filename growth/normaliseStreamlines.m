function [m,maxerr] = normaliseStreamlines( m, change )
%m = normaliseStreamlines( m, change )
%   Force all barycentric coordinates and directions to have sum
%   respectively 1 and 0, and norm 1. Where barycentric coordinates are all
%   zero (meaning undefined), they are left as all zero. Where barycentric
%   directions are all zero, they are replaced by [NaN NaN NaN].
%
%   If CHANGE is true (the default) then M will be modified to have the
%   normalised values. Otherwise, M is left unchanged but MAXERR is still
%   returned.
%
%   We should be consistent and either use [0 0 0] for all undefined values
%   or [NaN NaN NaN].

    maxerr = 0;
    if isempty(m) || isempty( m.tubules )
        return;
    end
    
    if nargin < 2
        change = 0;
    end

    for i=1:length(m.tubules.tracks)
        bcs = m.tubules.tracks(i).barycoords;
        s = sum(bcs,2);
        maxerr = max(maxerr,max(abs(s-1)));
        dbc = m.tubules.tracks(i).directionbc;
        maxerr = max(maxerr,abs(sum(dbc)));
        
        if change
            bcs(bcs < 0) = 0;
            s = sum(bcs,2);
            if s > 0
                bcs = bcs ./ s;
            end
            dbc = dbc - mean(dbc);
            n = norm(dbc);
            if n > 0
                dbc = dbc/norm(dbc);
            end
            m.tubules.tracks(i).directionbc = dbc;
            dg = streamlineGlobalDirection( m, m.tubules.tracks(i) );
            m.tubules.tracks(i).barycoords = bcs;
            m.tubules.tracks(i).directionglobal = dg;
        end
    end
end
