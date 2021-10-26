function ok = geom2dae( file, geometries )
%geom2dae( file, geometries )
%   Write a set of Geometry objects to a DAE file.
%   FILE can be either a filename or an open file descriptor.

    if isempty( regexp( file, '\.dae$', 'once' ) )
        file = [ file, '.dae' ];
    end
    xmlstack = XMLstack.new( file );
    ok = isopen( xmlstack );
    if ~ok
        return;
    end
    
    % If geometries is a single Geometry with no faces but non-empty
    % children, replace it by the children.
    if (length(geometries)==1) && isEmptyGeometry( geometries )
        geometries = geometries.children;
    end
    
    materials = Material.empty();
    for gi=1:length(geometries)
        g = geometries(gi);
        nm = length(g.material);
        materials((end+1):(end+nm)) = g.material;
        if isempty(g.facemat) && ~isempty(g.material)
            % Fix missing g.facemat.
            g.facemat = zeros( size(g.facevxs,1), 1 );
        end
    end
    [materials,ia,ic] = unique(materials);
%     materialIDs = {materials.id};
    % Would like to force unique names.
%     materialDict = makedictionary( materialIDs );
    
    sceneID ='Scene';
    timestamp = zulutime();
    
    beginxmlelement( xmlstack, 'COLLADA', 'xmlns', 'http://www.collada.org/2005/11/COLLADASchema', 'version', '1.4.1' );
    beginxmlelement( xmlstack, 'asset' );
    beginxmlelement( xmlstack, 'contributor' );
    contentxmlelement( xmlstack, 'author', 'ProcArch' );
    contentxmlelement( xmlstack, 'authoring_tool', 'ProcArch201609' );
    endxmlelement( xmlstack, 'contributor' );
    contentxmlelement( xmlstack, 'created', timestamp );
    contentxmlelement( xmlstack, 'modified', timestamp );
    contentxmlelement( xmlstack, 'unit', '', 'name', 'meter', 'meter', '1' );
    contentxmlelement( xmlstack, 'up_axis', 'Z_UP' );
    endxmlelement( xmlstack, 'asset' );
    
    contentxmlelement( xmlstack, 'library_images', '' );
    
    if isempty(materials)
        contentxmlelement( xmlstack, 'library_effects' );
    else
        beginxmlelement( xmlstack, 'library_effects' );
        for mi=1:length(materials)
            material2dae( xmlstack, materials(mi) );
        end
        endxmlelement( xmlstack, 'library_effects' );
    end
    
    beginxmlelement( xmlstack, 'library_materials' );
    for mi=1:length(materials)
        m = materials(mi);
        materialID = [m.id '-material'];
        materialEffectID = [m.id '-effect'];
        beginxmlelement( xmlstack, 'material', 'id', materialID, 'name', m.id );
        contentxmlelement( xmlstack, 'instance_effect', '', 'url', idref(materialEffectID) );
        endxmlelement( xmlstack, 'material' );
    end
    endxmlelement( xmlstack, 'library_materials' );
    
    beginxmlelement( xmlstack, 'library_geometries' );
    for gi=1:length(geometries)
        g = geometries(gi);
        objectName = g.id;
        meshName = [g.id '-mesh'];
        meshPositionsID = [meshName '-positions'];
        meshPositionsArrayID = [meshPositionsID '-array'];
        meshVerticesID = [meshName '-vertices'];

        haveNormals = ~isempty(g.normal);
        if haveNormals
            meshNormalsID = [meshName '-normals'];
            meshNormalsArrayID = [meshNormalsID '-array'];
        end
        haveUV = ~isempty(g.uv);
        if haveUV
            meshUVID = [meshName '-map'];
            meshUVArrayID = [meshUVID '-array'];
        end
        haveColor = ~isempty(g.color);
        if haveColor
            meshColorID = [meshName '-color'];
            meshColorArrayID = [meshColorID '-array'];
        end
        beginxmlelement( xmlstack, 'geometry', 'id', meshName, 'name', objectName );
        beginxmlelement( xmlstack, 'mesh' );

        beginxmlelement( xmlstack, 'source', 'id', meshPositionsID );
        contentxmlelement( xmlstack, 'float_array', floatstring( g.vxs' ), 'id', meshPositionsArrayID, 'count', intstring( numel(g.vxs) ) );
        XYZtechnique( xmlstack, 'XYZ', meshPositionsArrayID, size(g.vxs,1) );
        endxmlelement( xmlstack, 'source' );

        if haveNormals
            beginxmlelement( xmlstack, 'source', 'id', meshNormalsID );
            contentxmlelement( xmlstack, 'float_array', floatstring( g.normal' ), 'id', meshNormalsArrayID, 'count', intstring( numel(g.normal) ) );
            XYZtechnique( xmlstack, 'XYZ', meshNormalsArrayID, size(g.normal,1) );
            endxmlelement( xmlstack, 'source' );
        end

        if haveUV
            beginxmlelement( xmlstack, 'source', 'id', meshUVID );
            contentxmlelement( xmlstack, 'float_array', floatstring( g.uv' ), 'id', meshUVArrayID, 'count', intstring( numel(g.uv) ) );
            XYZtechnique( xmlstack, 'ST', meshUVArrayID, size(g.uv,1) );
            endxmlelement( xmlstack, 'source' );
        end

        if haveColor
            beginxmlelement( xmlstack, 'source', 'id', meshColorID );
            contentxmlelement( xmlstack, 'float_array', floatstring( g.color' ), 'id', meshColorArrayID, 'count', intstring( numel(g.color) ) );
            XYZtechnique( xmlstack, 'RGB', meshColorArrayID, size(g.color,1) );
            endxmlelement( xmlstack, 'source' );
        end

        beginxmlelement( xmlstack, 'vertices', 'id', meshVerticesID );
        contentxmlelement( xmlstack, 'input', '', 'semantic', 'POSITION', 'source', idref(meshPositionsID) );
        endxmlelement( xmlstack, 'vertices' );

        if isempty(g.material)
            writePolyset( xmlstack, g, 0 );
        else
            for mi=1:length(g.material)
                writePolyset( xmlstack, g, mi );
            end
        end

        xmlstack.popto( 'geometry' );
    end
    endxmlelement( xmlstack, 'library_geometries' );
    
    contentxmlelement( xmlstack, 'library_controllers', '' );
    
    beginxmlelement( xmlstack, 'library_visual_scenes' );
    beginxmlelement( xmlstack, 'visual_scene', 'id', sceneID, 'name', sceneID );
    for gi=1:length(geometries)
        g = geometries(gi);
        objectName = g.id;
        meshName = [g.id '-mesh'];
        beginxmlelement( xmlstack, 'node', 'id', objectName, 'name', objectName, 'type', 'NODE' );
        transform = eye(4);  % TO BE REVISED: if g does not have transforms applied we need to compute this.
        contentxmlelement( xmlstack, 'matrix', floatstring( transform ), 'sid', 'transform' );
        if isempty(g.material)
            contentxmlelement( xmlstack, 'instance_geometry', '', 'url', idref(meshName), 'name', objectName );
        else
            beginxmlelement( xmlstack, 'instance_geometry', 'url', idref(meshName), 'name', objectName );
            beginxmlelement( xmlstack, 'bind_material' );
            beginxmlelement( xmlstack, 'technique_common' );
            for mi=1:length(g.material)
                m = g.material(mi);
                materialID = [m.id '-material'];
                contentxmlelement( xmlstack, 'instance_material', '', 'symbol', materialID, 'target', idref(materialID) );
            end
            xmlstack.popto( 'instance_geometry' );
        end
        endxmlelement( xmlstack, 'node' );
    end
    endxmlelement( xmlstack, 'visual_scene' );
    endxmlelement( xmlstack, 'library_visual_scenes' );
    
    beginxmlelement( xmlstack, 'scene' );
    contentxmlelement( xmlstack, 'instance_visual_scene', '', 'url', idref(sceneID) );
    endxmlelement( xmlstack, 'scene' );

    endxmlelement( xmlstack, 'COLLADA' );
    xmlstack.close();
end

function idr = idref( id )
    idr = ['#' id];
end

function XYZtechnique( xmlstack, channels, sourceid, count )
    numchannels= length(channels);
    beginxmlelement( xmlstack, 'technique_common' );
    beginxmlelement( xmlstack, 'accessor', 'source', idref(sourceid), 'count', intstring( count ), 'stride', intstring( numchannels ) );
    for i=1:numchannels
        contentxmlelement( xmlstack, 'param', '', 'name', channels(i), 'type', 'float' );
    end
    endxmlelement( xmlstack, 'accessor' );
    endxmlelement( xmlstack, 'technique_common' );
end

function writePolyset( xmlstack, g, mi )
    meshName = [g.id '-mesh'];
    meshVerticesID = [meshName '-vertices'];
    haveNormals = ~isempty(g.normal);
    if haveNormals
        meshNormalsID = [meshName '-normals'];
    end
    haveUV = ~isempty(g.uv);
    if haveUV
        meshUVID = [meshName '-map'];
    end
    haveColor = ~isempty(g.color);
    if haveColor
        meshColorID = [meshName '-color'];
    end

    havematerials = mi > 0;
    if havematerials
        selectedFaces = g.facemat==mi-1;  % mi is 1-indexed, g.facemat is 0-indexed.
        numselected = sum(selectedFaces);
    else
        numselected = size(g.facevxs,1);
        selectedFaces = 1:numselected;
    end
    if numselected > 0
        facedata = g.facevxs(selectedFaces,:);
        vxsPerFace = sum(validindexes(facedata),2);
        facedata = reshape( facedata', 1, [] );
        facedata = facedata( validindexes(facedata) );
        numfacesstring = intstring( length(selectedFaces) );
        numcornersstring = intstring( length(facedata) );
        if havematerials
            materialID = [g.material(mi).id '-material'];
            beginxmlelement( xmlstack, 'polylist', 'material', materialID, 'count', numfacesstring );
        else
            beginxmlelement( xmlstack, 'polylist', 'count', numfacesstring );
        end
        contentxmlelement( xmlstack, 'input', '', 'semantic', 'VERTEX', 'source', idref(meshVerticesID), 'offset', '0' );
        if haveNormals
            facevxnormals = reshape( g.facevxnormal(selectedFaces,:)', 1, [] );
            facevxnormals = facevxnormals( validindexes(facevxnormals) );
            contentxmlelement( xmlstack, 'input', '', 'semantic', 'NORMAL', 'source', idref(meshNormalsID), 'offset', intstring( size(facedata,1) ) );
            facedata = [ facedata; facevxnormals ];
        end
        if haveUV
            facevxuvs = reshape( g.facevxuv(selectedFaces,:)', 1, [] );
            facevxuvs = facevxuvs( validindexes(facevxuvs) );
            contentxmlelement( xmlstack, 'input', '', 'semantic', 'TEXCOORD', 'source', idref(meshUVID), 'offset', intstring( size(facedata,1) ), 'set', '0' );
            facedata = [ facedata; facevxuvs ];
        end
        if haveColor
            facevxcolors = reshape( g.facevxcolor(selectedFaces,:)', 1, [] );
            facevxcolors = facevxcolors( validindexes(facevxcolors) );
            contentxmlelement( xmlstack, 'input', '', 'semantic', 'COLOR', 'source', idref(meshColorID), 'offset', intstring( size(facedata,1) ) );
            facedata = [ facedata; facevxcolors ];
        end
        contentxmlelement( xmlstack, 'vcount', intstring( vxsPerFace ) );
        contentxmlelement( xmlstack, 'p', intstring( facedata ) );
        endxmlelement( xmlstack, 'polylist' );
    end
end

    