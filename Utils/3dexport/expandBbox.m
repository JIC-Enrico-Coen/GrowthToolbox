function bbox = expandBbox( bbox, amount, mode )
    if isempty(bbox)
        return;
    end
    if nargin < 3
        mode = 'abs';
    end
    lo = bbox([1 3 5]);
    hi = bbox([2 4 6]);
    centre = (lo+hi)/2;
    if strcmp( mode, 'abs' )
        offset = max(hi-centre) * amount;
        bbox = [ bbox([1 3 5])-offset; bbox([2 4 6])+offset ];
    else
        bbox = [ centre + (1+amount)*(lo-centre); centre + (1+amount)*(hi-centre) ];
    end
end
