function printStringTable( varargin )
    if nargin==0
        return;
    end
    if isnumeric( varargin{1} )
        fid = varargin{1};
        varargin(1) = [];
    else
        fid = 1;
    end
    if isempty(varargin)
        return;
    end
    strings = varargin{1};
    if isempty(strings)
        return;
    end
    varargin(1) = [];
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'alignment', '', 'margin', 2 );

    len = zeros( size(strings) );
    for ci=1:size(strings,2)
        for ri=1:size(strings,1)
            len(ri,ci) = length(strings{ri,ci});
        end
    end
    
    colwidths = max( len, [], 1 );
    rowfmt = sprintf( '%%%ds', colwidths+s.margin );
    rowfmt(end+1) = newline();
    strings = strings';
    fprintf( fid, rowfmt, strings{:} );
end
