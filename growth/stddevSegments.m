function [mn,sd] = stddevSegments( varargin )
%[mn,sd] = stddevTubuleSegments( m, dim )
%[mn,sd] = stddevTubuleSegments( p0, dim )
%[mn,sd] = stddevTubuleSegments( p0, p1, dim )

    if isnumeric( varargin{1} )
        if nargin == 2
            p0 = varargin{1}(1:(end-1),:);
            p1 = varargin{1}(2:end,:);
            dim = varargin{2};
        elseif nargin==3
            p0 = varargin{1};
            p1 = varargin{2};
            dim = varargin{3};
        end
        weights = sqrt( sum( (p1-p0).^2, 2 ) );
        midsegs = (p0(:,dim) + p1(:,dim))/2;
        segdiffs = p1(:,dim) - p0(:,dim);
    else
        m = varargin{1};
        dim = varargin{2};
        weights = [ m.tubules.tracks.segmentlengths ]';
        numsegs = length(weights);
        midsegs = zeros(numsegs,1);
        segdiffs = zeros(numsegs,1);
        xi = 0;
        for ti=1:length(m.tubules.tracks)
            % Get the starts and ends.
            t = m.tubules.tracks(ti);
            numsegs1 = size( t.globalcoords, 1 );
            x0 = t.globalcoords(1:(end-1),dim);
            x1 = t.globalcoords(2:end,dim);
            midsegs( (xi+1):(xi+numsegs1-1), 1 ) = (x0+x1)/2;
            segdiffs( (xi+1):(xi+numsegs1-1), 1 ) = x1 - x0;
            xi = xi+numsegs1-1;
        end
    end

    totalweight = sum(weights);
    mn = sum(weights .* midsegs)/totalweight;
    sd = sqrt( sum( weights.*( midsegs.^2 + (segdiffs.^2)/12 ) )/totalweight );
end
