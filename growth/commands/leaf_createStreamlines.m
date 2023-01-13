function m = leaf_createStreamlines( m, varargin )
%m = leaf_createStreamlines( m, ... )
%   Initiate streamlines at specified locations.
%
%   Options:
%
%   startpos: an N*3 array of N 3D points.  A streamline will be
%       initiated at the points on the surface of the mesh closest to
%       these points.
%
%   downstream: a single boolean or an N-element vector of booleans,
%       specifying whether the streamlines grow down the gradient of
%       the associated morphogen or up it.  The default is true.
%
%   speed: a single non-negative number or an N-element vector of them,
%       specifying the rate of growth of each streamline.  The default is
%       zero.
%
%   morphogen: NOT IMPLEMENTED.  POLARISER IS ALWAYS USED AS THE
%       STREAMLINE MORPHOGEN. 
%       A morphogen index or name, or an N-element array of them,
%       specifying which morphogen's gradient each streamline grows along.
%       The default is 'POLARISER'.  When the morphogen is POLARISER, the
%       gradient vector will be taken from m.gradpolgrowth.  For any other
%       morphogen, the gradient will be calculated from the morphogen
%       values.  Note that gradpolgrowth is subject to freezing and minimum
%       threshold, while other morphogens will not be.
%
%   See also: leaf_growStreamlines, leaf_deleteStreamlines.
%
%   Topics: Streamlines.
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
        'startpos', [], ...
        'elementindex', zeros(1,0,'int32'), ...
        'barycoords', zeros(0,3), ...
        'length', 0, ...
        'downstream', true, ...
        'morphogen', 'POLARISER', ...
        'directionbc', [], ...
        'directionglobal', [], ...
        'creationtimes', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'startpos', 'elementindex', 'barycoords', 'length', 'downstream', 'morphogen', 'directionbc', 'directionglobal', 'creationtimes' );
    if ~ok, return; end
    
    s.morphogen = FindMorphogenIndex( m, s.morphogen );
    numstreamlines = size(s.barycoords,1);
    if numstreamlines==0
        numstreamlines = size(s.startpos,1);
        if numstreamlines==0
            return;
        end
        s.elementindex = zeros( numstreamlines, 1 );
        s.barycoords = zeros( numstreamlines, 3 );
        for i=1:numstreamlines
            [ s.elementindex(i), s.barycoords(i,:), ~, ~ ] = findFE( m, s.startpos(i,:) );
        end
    end
    if isempty( s.creationtimes )
        s.creationtimes = m.globalDynamicProps.currenttime + zeros(numstreamlines,1);
    else
        s.creationtimes = s.creationtimes(:);
    end
    
    if isempty( s.directionbc ) && isempty( s.directionglobal )
        for i=1:length( s.elementindex )
            vxs = m.nodes( m.tricellvxs( s.elementindex(i), : ), : );
            s.directionbc(i,:) = randDirectionBC( vxs );
        end
    end
    localFromGlobal = isempty( s.directionbc ) && ~isempty( s.directionglobal );
    globalFromLocal = ~isempty( s.directionbc ) && isempty( s.directionglobal );

    ss = transposeStructOfArrays( s, numstreamlines );

    streamline = m.tubules.defaulttrack;
    streamline = repmat( streamline, numstreamlines, 1 );
    currentID = m.tubules.maxid;
    
%     timedFprintf( 'Creating %d tubules.\n', numstreamlines );
    newtubuleinfo = zeros( numstreamlines, 5 );
    newtubuleinfo(:,5) = double(Steps(m)+1);
    for i=1:numstreamlines
        streamline(i).id = currentID+i;
        streamline(i).barycoords = ss(i).barycoords;
        streamline(i).vxcellindex = ss(i).elementindex;
        streamline(i).segcellindex = ss(i).elementindex;
        streamline(i).directionbc = ss(i).directionbc;
        streamline(i).directionglobal = ss(i).directionglobal;
        if localFromGlobal
            streamline(i).directionbc = streamlineLocalDirection( m, streamline(i) );
        end
        if globalFromLocal
            streamline(i).directionglobal = streamlineGlobalDirection( m, streamline(i) );
        end
        streamline(i).globalcoords = streamlineGlobalPos( m, streamline(i) );
        streamline(i).starttime = ss(i).creationtimes;
        streamline(i).endtime = ss(i).creationtimes;
        streamline(i) = setStructTypes( streamline(i), ...
            'id', 'int32', ...
            'vxcellindex', 'int32', ...
            'segcellindex', 'int32', ...
            'barycoords', 'double', ...
            'globalcoords', 'double', ...
            'segmentlengths', 'double', ...
            'downstream', 'logical', ...
            'morphogen', 'int32', ...
            'directionbc', 'double', ...
            'directionglobal', 'double', ...
            'status', 'struct' );
        newtubuleinfo(i,1:4) = [ streamline(i).segcellindex, streamline(i).barycoords ];
    end
    
    if isempty(m.tubules.tracks)
        m.tubules.tracks = streamline;
    else
        m.tubules.tracks( (end+1):(end+numstreamlines) ) = streamline;
    end
    m.tubules.maxid = m.tubules.maxid + numstreamlines;
    
    % Update stats.
%     m.tubules.statistics.created = m.tubules.statistics.created + numstreamlines;
    
    if ~isfield(  m.tubules.statistics, 'creationinfo' )
        m.tubules.statistics.creationinfo = zeros(0,5);
    end
    m.tubules.statistics.creationinfo = [ m.tubules.statistics.creationinfo; newtubuleinfo ];
end
