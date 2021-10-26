function [m,ok] = leaf_flatten( m, varargin )
%[m,ok] = leaf_flatten( m )
%   Flatten each of the connected components of m.
%
%   Options:
%       interactive: If true (default is false), then the flattening will
%                    be carried out interactively.  The user can skip the
%                    flattening of components that appear not to be well
%                    flattenable, or cancel the whole operation.
%       method:      One of the following:
%                       'laplacian'  (NOT IMPLEMENTED)
%                       'geodesic'  (NOT IMPLEMENTED)
%                       'ballandspring' (the default)
%       getdeformation:   Boolean.  If true (the default), the deformation
%                    that would restore the shape of each flattened element
%                    is calculated and stored in
%                    m.celldata(:).cellThermExpGlobalTensor.  If the leaf
%                    is then grown with the property 'useGrowthTensors' set
%                    to true, then in one unit of time its original shape
%                    should be (approximately) restored.
%       bsiters:     An integer.  The maximum number of iterations to
%                    perform in the ball-and-spring phase.  If 0, the
%                    ball-and-spring phase will be omitted.
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
                       'interactive', false, ...
                       'method', 'ballandspring', ...
                       'getdeformation', true, ...
                       'bsiters', 500 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'interactive', 'method', 'getdeformation', 'bsiters' );
    if ~ok, return; end

    USE_DISPLACEMENTS_TO_RECORD_DEFORMATION = false;
    if s.getdeformation
        if USE_DISPLACEMENTS_TO_RECORD_DEFORMATION
            oldprismnodes = m.prismnodes; %#ok<UNRCH>
        else
            oldnodesA = m.prismnodes(1:2:end,:);
            oldnodesB = m.prismnodes(2:2:end,:);
            numFEs = size(m.tricellvxs,1);
            trianglesA = zeros( 3, 3, numFEs );
            trianglesB = zeros( 3, 3, numFEs );
            if isempty( m.cellFramesB )
                for ci=1:numFEs
                    trianglesA(:,:,ci) = oldnodesA( m.tricellvxs( ci, : ), : )*m.cellFrames(:,:,ci);
                    trianglesA(:,3,ci) = trianglesA(:,3,ci) - trianglesA(3,3,ci);
                    trianglesB(:,:,ci) = oldnodesB( m.tricellvxs( ci, : ), : )*m.cellFrames(:,:,ci);
                    trianglesB(:,3,ci) = trianglesB(:,3,ci) - trianglesB(3,3,ci);
                end
            else
                for ci=1:numFEs
                    trianglesA(:,:,ci) = oldnodesA( m.tricellvxs( ci, : ), : )*m.cellFramesA(:,:,ci);
                    trianglesA(:,3,ci) = trianglesA(:,3,ci) - trianglesA(3,3,ci);
                    trianglesB(:,:,ci) = oldnodesB( m.tricellvxs( ci, : ), : )*m.cellFramesB(:,:,ci);
                    trianglesB(:,3,ci) = trianglesB(:,3,ci) - trianglesB(3,3,ci);
                end
            end
        end
    end
    
    [m,ok] = flattenComponents( m, s.interactive, s.method, [], s.bsiters );
    numFEs = getNumberOfFEs( m );
    
    if s.getdeformation
        if USE_DISPLACEMENTS_TO_RECORD_DEFORMATION
            m.displacements = m.prismnodes - oldprismnodes; %#ok<UNRCH>
            m = computeResiduals( m, 1 );
        else
            for ci=1:numFEs
                currenttri = m.nodes( m.tricellvxs( ci, : ), [1 2] );
                originaltriA = trianglesA(:,[1 2],ci);
                [gA,vA,dA] = estimateGrowth( currenttri, originaltriA );
                originaltriB = trianglesB(:,[1 2],ci);
                [gB,vB,dB] = estimateGrowth( currenttri, originaltriB );
                m.celldata(ci).cellThermExpGlobalTensor = ...
                    [ make6vector( gA )', make6vector( gB )' ];
%                 fprintf( 1, '%8.4f %8.4f %8.4f %8.4f\n', ...
%                     reshape( [ [gA; vA; dA'], [gB; vB; dB'] ]', [], 1 ) );
%                 fprintf( 1, '\n' );
            end
        end
    end
end

