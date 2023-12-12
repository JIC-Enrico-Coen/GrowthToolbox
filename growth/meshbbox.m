function bbox = meshbbox( m, includedecor, margin )
%bbox = meshbbox( m, includedecor, margin )
%   Calculate the bounding box of the mesh.  If includedecor is true,
%   allowance will also be made for the various items drawn at a distance
%   from the mesh surface: biological cells, polariser gradient arrows,
%   etc. If margin is positive, the bounding box will be enlarged about its
%   centre by an equal absolute amount in all directions.  That amount will
%   be the MARGIN multiplied by half the minimum nonzero dimension of the
%   unenlarged box. If all dimensions are zero, the value of MARGIN will be
%   used directly.

    if nargin < 3
        includedecor = false;
    end
    if nargin < 2
        margin = 0;
    end

    isvol = isVolumetricMesh( m );
    if isvol
        bbox = aabbox( m.FEnodes );
    else
        pbbox = aabbox( m.prismnodes );
        if m.plotdefaults.thick
            bbox = pbbox;
        else
            bbox = aabbox( m.nodes );
            zerothickness = bbox(1,:)==bbox(2,:);
            bbox(:,zerothickness) = pbbox(:,zerothickness);
        end
    end
    
    if ~isvol && includedecor
        ALWAYS = true;  % Maybe it's better to always leave space for all the possible decorations.
        extra = 0;
        thickness = sum( sqrt( sum( (m.prismnodes(2:2:end,:) - m.prismnodes(1:2:end,:)).^2, 2 ) ) )/size(m.nodes,1);
        decorlength = m.plotdefaults.decorscale * m.globalDynamicProps.cellscale;
        if ALWAYS || m.plotdefaults.drawtensoraxes
            extra = max( extra, m.plotdefaults.tensoroffset*thickness + decorlength );
        end
        if ALWAYS || m.plotdefaults.drawstreamlines && ~isempty( m.tubules.tracks )
            extra = max( extra, abs(m.plotdefaults.streamlineoffset)*thickness );
        end
        if ALWAYS || m.plotdefaults.drawgradients
            extra = max( extra, m.plotdefaults.gradientoffset*thickness );
        end
        if ALWAYS || m.plotdefaults.drawcontours
            extra = max( extra, m.plotdefaults.contouroffset*thickness );
        end
        if ALWAYS || m.plotdefaults.drawnormals
            extra = max( extra, m.plotdefaults.normaloffset*thickness + decorlength );
        end
        if ALWAYS || m.plotdefaults.drawdisplacements
            extra = max( extra, decorlength );
        end
        if ALWAYS || m.plotdefaults.drawsecondlayer && hasNonemptySecondLayer( m )
            extra = max( extra, m.plotdefaults.layeroffset*thickness );
        end
        bbox = bbox + [ -extra -extra -extra; extra extra extra ];
    end
    
    if margin > 0
        bboxrange = min(bbox(2,:)-bbox(1,:))/2;
        minrange = min( bboxrange(bboxrange>0) );
        if isempty( minrange )
            minrange = 1;
        end
        bbox = bbox + margin * minrange*[ -1 -1 -1; 1 1 1 ];
    end
end
