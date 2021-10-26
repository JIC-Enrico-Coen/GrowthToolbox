function sl = newemptysecondlayer( oldsl )
%sl = newemptysecondlayer()
%   Create a second layer containing no cells.  If oldsl is supplied, all
%   information not relating to the cells is retained (e.g. plotting
%   options, cellular morphogens, etc.).

% The second layer contains the following information:
% For each clone cell ci:
%       cells(ci).vxs(:)       A list of all its vertexes, in clockwise order.
%       cells(ci).edges(:)     A list of all its edges, in clockwise order.
%           These cannot be 2D arrays, since different cells may have
%           different numbers of vertexes or edges.
%       cellcolor(ci,1:3):     Its colour.
%       side(ci)               True if it should be plotted on the A side.
%       cloneindex(ci)         Its clone number.
%       cellarea(ci)           Its current area.
%       celltargetarea(ci)     ??
%       areamultiple(ci)       ??
% For each clone vertex vi:
%       vxFEMcell(vi)          Its FEM cell index.
%       vxBaryCoords(vi,1:3)   Its FEM cell barycentric coordinates.
%       cell3dcoords(vi,1:3)   Its 3D coordinates (which can be calculated
%                              from the other data).
% For each clone edge ei:
%       edges(ei,1:4)          The indexes of the clone vertexes at its ends
%                              and the clone cells on either side (the
%                              second one is 0 if absent).  This can be
%                              computed from the other data.
%       generation(ei)         Its generation number, used in order to
%                              colour new edges differently from old ones.
%
% Other componentsL:
%       splitThreshold         A single real number.
%       jiggleAmount           A single real number.
%       averagetargetarea      A single real number.

    global gSecondLayerColorInfo gDefaultPlotOptions
    global gPerBioCellFields gPerBioEdgeFields gPerBioVertexFields
    global gCellFactorRoles
    
    setGlobals();

    if nargin < 1
        oldsl = [];
    end

    sl = oldsl;
    sl.splitThreshold = 0;
    sl.cells = [];
    sl.cellcolor = zeros(0,3, 'single');
    sl.side = true(0,1);
    sl.cloneindex = int32([]);
    sl.cellvalues = [];
    sl.cellpolarity = [];
    sl.areamultiple = zeros(1,0);
    sl.cellarea = zeros(1,0);
    sl.celltargetarea = zeros(1,0);
    
    sl.vxFEMcell = zeros(0,1, 'int32');
    sl.vxBaryCoords = zeros(0,0, 'single');
    sl.cell3dcoords = zeros(0,3, 'single');
    
    sl.edges = zeros(0,4);
    sl.interiorborder = false(0,1);
    sl.generation = zeros(0,1,'int32');
    sl.edgepropertyindex = ones(1,0,'int32');
    
	sl.cellid = zeros(0,1,'int32');  % unique id per cell
	sl.cellparent = zeros(0,1,'int32');  % maps each current cell to the id of its parent
	sl.cellidtoindex = zeros(0,1,'int32');  % one entry for each id that has ever existed.
	    % The index of currently existing cells, zero for others.
    sl.cellidtotime = zeros(0,2,'double');  % The lifetime of the cell, beginning with creation
        % or splitting of its parent, and ending with its own splitting.
        % If it has not split, the latter number will be NaN.
        
    sl.cellfactorroles = MakeNameIndex( gCellFactorRoles, zeros(1,length(gCellFactorRoles)) );
%     sl.cellfactorroles = MakeNameIndex( {}, zeros(1,0) );

    if isempty( oldsl )
        sl.valuedict = MakeNameIndex();
        sl.colorscale = [];
        sl.averagetargetarea = 0;
        sl.jiggleAmount = 0;
        colorinfo = gSecondLayerColorInfo;
        sl.customcellcolorinfo = colorinfo;
        sl.cellcolorinfo = colorinfo;
        sl.cellcolorinfo(:) = [];
        sl.newedgeindex = 1;
        sl.indexededgeproperties = struct( 'LineWidth', gDefaultPlotOptions.bioAlinesize, 'Color', gDefaultPlotOptions.bioAlinecolor );
    end
    
    sl.percellfields = gPerBioCellFields;
    sl.peredgefields = gPerBioEdgeFields;
    sl.pervertexfields = gPerBioVertexFields;
    sl.cellvalue_plotpriority = zeros(1,size(sl.cellvalues,2));
    sl.cellvalue_plotthreshold = zeros(1,size(sl.cellvalues,2));
    
    sl.visible = struct( 'cells', [] );
        
    sl = newemptybiodata( sl );
end
