function [vxs,cells,origins] = cellgridcylinder( varargin )

    s = struct( varargin{:} );
    s = defaultfields( s, ...
        'centre1', [0 0 -1], 'centre2', [0 0 1], ...
        'rings', 4, 'divs', 6, ...
        'havecap1', false, 'havecap2', false, 'havecylinder', true );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'centre1', 'centre2', ...
        'rings', 'divs', ...
        'havecap1', 'havecap2', 'havecylinder' );
    if ~ok, return; end
    
    cylheight = norm(s.centre2-s.centre1);
    s.havecylinder = s.havecylinder && (s.rings > 0) && (cylheight > 0);
    vdivs = ceil(s.divs/2);
    
    if s.havecylinder
        [cylvxs,cylcells,cylorigins] = cylgrid( s.rings, s.divs );
        cylvxs(:,3) = cylvxs(:,3) * cylheight - cylheight/2;
        cylorigins(:,3) = cylorigins(:,3) * cylheight - cylheight/2;
    end
    if s.havecap1
        [cap1vxs,cap1cells,cap1origins] = hemispheregrid( vdivs, s.divs );
    end
    if s.havecap2
        [cap2vxs,cap2cells,cap2origins] = hemispheregrid( vdivs, s.divs );
    end
    if s.havecylinder
        vxs = cylvxs;
        cells = cylcells;
        origins = cylorigins;
        if s.havecap1
            [vxs,cells,origins] = weld( cylvxs,cylcells,cylorigins, cap1vxs,cap1cells,cap1origins, welds );
        end
        if s.havecap2
            [vxs,cells,origins] = weld( cylvxs,cylcells,cylorigins, cap2vxs,cap2cells,cap2origins, welds );
        end
    elseif s.havecap1
        vxs = cap1vxs;
        cells = cap1cells;
        origins = cap1origins;
        if s.havecap2
            [vxs,cells,origins] = weld( cap1vxs,cap1cells,cap1origins, cap2vxs,cap2cells,cap2origins, welds );
        end
    elseif s.havecap2
        vxs = cap2vxs;
        cells = cap2cells;
        origins = cap2origins;
    else
        vxs = [];
        cells = [];
        origins = [];
    end
end

function [vxs,cells,origins] = weld( vxs1, cells1, origins1, vxs2, cells2, origins2, welds )
    % NOT IMPLEMENTED.
end

function [vxs,cells,origins] = hemispheregrid( stepslat, stepslong )
    theta = linspace( 0, pi*2, stepslong+1 )';
    theta(end) = [];
    ct = cos(theta);
    st = sin(theta);
    phi = linspace( 0, pi/2, stepslat+1 );
    cp = cos(phi);
    sp = sin(phi);
    rr = reshape( repmat( cp, stepslong, 1 ), [], 1 );
    xx = repmat( ct, stepslat+1, 1 ) .* rr;
    yy = repmat( st, stepslat+1, 1 ) .* rr;
    zz = reshape( repmat( sp, stepslong, 1 ), [], 1 );
    vxs = [ xx(:) yy(:) zz(:) ];
    origins = zeros( size(vxs) );
    indexes = reshape( 1:length(xx), stepslong, stepslat+1 );
    i1 = indexes(:,1:(end-1));
    i2 = i1([2:end 1],:);
    i3 = indexes(:,2:end);
    i4 = i3([2:end 1],:);
    cells = [ i1(:) i2(:) i4(:) i3(:) ];  % Leaves degenerate edges at pole.
end

function [vxs,cells,origins] = cylgrid( stepsup, stepsaround )
    theta = linspace( 0, pi*2, stepsaround+1 )';
    theta(end) = [];
    c = cos(theta);
    s = sin(theta);
    heights = linspace( 0, 1, stepsup+1 );
    xx = repmat( c, stepsup+1, 1 );
    yy = repmat( s, stepsup+1, 1 );
    zz = reshape( repmat( heights, stepsaround, 1 ), [], 1 );
    vxs = [ xx yy zz ];
    origins = [ zeros(length(xx),2), zz ];
    indexes = reshape( 1:length(xx), stepsaround, stepsup+1 );
    i1 = indexes(:,1:(end-1));
    i2 = i1([2:end 1],:);
    i3 = indexes(:,2:end);
    i4 = i3([2:end 1],:);
    cells = [ i1(:) i2(:) i4(:) i3(:) ];
end