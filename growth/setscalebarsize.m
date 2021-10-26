function setscalebarsize( m )
    if isempty(m)
        return;
    end
    if isfield( m, 'mesh' ) && isfield( m, 'scalebar' ) && ~isempty( m.mesh )
        m = m.mesh;
    end
    if isfield( m, 'scalebar' )
        % m is actually a set of figure handles, not a mesh. There is no
        % mesh present.
        sb = m.scalebar;
        theaxes = m.picture;
        theunit = 1;
        unitname = '';
        relpos = [0 0];
        pixelheight = 20;
    elseif isfield( m, 'plotdefaults' )
        if isempty( m.pictures )
            return;
        end
        % m is a mesh.
%         sb = -ones( 1, length(m.pictures) );
        theaxes = reshape(m.pictures,1,[]);
        for i=1:length(m.pictures)
            h = guidata( m.pictures(1) );
            if ~isempty(h)
                sb(i) = h.scalebar;
            end
        end
        theunit = m.globalProps.scalebarvalue;
        unitname = m.globalProps.distunitname;
        relpos = min( 1, max( 0, m.plotdefaults.scalebarpos ) );
        pixelheight = max( 1, m.plotdefaults.scalebarheight );
    else
        % The arguments make no sense.
        return;
    end
    okitems = ishandle(sb) & ishandle(theaxes);
    sb = sb(okitems);
    theaxes = theaxes(okitems);
    if isempty(sb)
        return;
    end
    for i=1:length(sb)
        [pixelwidth,realwidth] = axissize( theaxes(i) );
        if theunit <= 0
            theunit = defaultScaleBarUnit( pixelwidth, realwidth );
        end
        if isnan( theunit )
            continue;
        end
        scaling = pixelwidth/realwidth;
        pixellength = scaling * theunit;
        axsize = get( theaxes(i), 'Position' );
        sboldpos = get( sb(i), 'Position' );
%             sbpos1 = positionScalebar( axsize([3 4]), [pixellength pixelheight], relpos, [2 0 1 0], sboldpos )
        ppos = get(get(sb,'Parent'),'Position');
        sbpos2 = absScaleBarPos( relpos, [pixellength pixelheight], ppos([3 4]), [2 0 1 0] );
        sbpos = [ sbpos2, ...
                  pixellength, ...
                  pixelheight ];
%         fprintf( 1, 'ssbs: Abs sb [%f %f %f %f], rel [%f %f], psize [%f %f]\n', sbpos, relpos, axsize([3 4]) );

        sbtext = sprintf( '%f', theunit );
        sbtext = [ regexprep( sbtext, '\.*0+$', '' ), unitname ];


        set( sb(i), 'Position', sbpos, 'String', sbtext );
    end
end

function p = positionScalebar( axsize, sbsize, relpos, inset, sboldpos )
    p = [ relpos1( axsize(1), sbsize(1), relpos(1), inset([1 2]), sboldpos(1) ), ...
          relpos1( axsize(2), sbsize(2), relpos(2), inset([3 4]), sboldpos(2) ) ];
end

function rp = relpos1( outerwidth, innerwidth, proportion, inset, sboldpos )
    rp = inset(1) + proportion * (outerwidth-(inset(1)+inset(2)) - innerwidth);
end
