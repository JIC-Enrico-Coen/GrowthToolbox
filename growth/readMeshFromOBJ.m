function mesh = readMeshFromOBJ( dirname, basename )
%mesh = readMeshFromOBJ( dirname, basename )
%    Read a mesh from the set of OBJ files in the given directory having the
%    given basename.  If basename is the name of a subdirectory, read the mesh
%    from the set of files contained in that subdirectory.
%    It does not matter whether dirname has a trailing '/' or not.
%    Basename should not contain wildcards.
%
%    If basename is empty, dirname will be taken to be the full file name
%    or directory name.
%
%    In each file, comments begin with a #, extend to the end of the
%    line, and are ignored.  Empty lines are ignored.  Leading and trailing
%    space is ignored.  Each remaining line is expected to begin with a
%    token, made of letters, digits, underscores, and hyphens (but hyphens
%    will be taken as equivalent to underscores).  The token is followed by
%    series of numbers separated by whitespace.  The same token must always
%    be followed by the same number of numbers.  Extra numbers will be
%    ignored and missing numbers set to zero, with a warning printed.
%    In addition, a line consisting entirely of numbers is allowed: in this
%    case the implied token name is the file extension (with invalid
%    characters removed).  If the file has no file extension, the basename
%    of the file is used.
%
%    The result of reading the raw data is a structure containing a field
%    for each different token that was seen.  The value of that field is a
%    matrix in which each row corresponds to a line of data readin from the
%    files.  When reading multiple files, it does not matter which file any
%    piece of data came from.
%
%    2008 Feb 27: readMeshFromOBJ cannot be used to read prim meshes, only
%    triangular meshes.

% This operates by first reading in all of the data, and then constructing
% a mesh from it.

    mesh = [];
    if nargin < 2, basename = ''; end

    rawmesh = readrawmesh( dirname, basename );
    if ~isempty(rawmesh)
        mesh = meshFromRawMesh( rawmesh );
    end

    if false
        fullname = fullfile( dirname, basename );
        [dirname,stem,ext] = fileparts(fullname);
        basename = [ stem, ext ];
        files = [];
        if isempty(ext)
            files = dir( [ fullname, '.*' ] );
        end
        if isempty(files)
            files = dir( fullname );
        end
        if isempty(files)
            fprintf( 1, 'No files or subdirectories %s found.\n', fullname );
            return;
        end
        df = files([files.isdir]);
        if (length(df) > 0) && (length(df) ~= length(files))
            fprintf( 1, 'Mixture of files and directories for %s.\n', fullname );
            return;
        end
        if length(df) > 0
            files = [];
            for x = df
                f1 = dir( [ dirname, x.name ] );
                f1 = f1(~[f1.isdir]);
                for i=1:length(f1)
                    f1(i).name = fullfile( x.name, f1(i).name );
                end
                files = [files;f1];
            end
            if isempty(files)
                fprintf( 1, 'No files found in subdirectories of %s with names %s or %s.*.\n', ...
                     dirname, basename, basename );
                return;
            end
        end
        rawmesh = [];
        formats = struct( ...
            ... % 'f', '%d', ...
            'x_growth', '%d %f %f %f' );
        for i=1:length(files)
            % read mesh info from file
            filename = fullfile( dirname, files(i).name );
            rawmesh = addToRawMesh( rawmesh, filename, formats );
        end
    end
  % rawmesh
  % rawfieldnames = fieldnames(rawmesh);
end

function [rawmesh,ok] = checkNumParams( rawmesh, fieldname, expnumber )
    ok = true;
    if ~isfield( rawmesh, fieldname ), return; end
    actualNumber = size(rawmesh.(fieldname),2);
    if any(actualNumber==expnumber), return; end
    if length(expnumber)==1
        if actualNumber > expnumber
            fprintf( 1, 'Field %s should have %d parameters, found %d. Excess ignored.\n', ...
                expnumber, actualNumber );
            rawmesh.(fieldname) = rawmesh.(fieldname)(:,1:expnumber);
            ok = false;
        elseif actualNumber < expnumber
            fprintf( 1, 'Field %s should have %d parameters, found %d.  Missing values set to zero.\n', ...
                expnumber, actualNumber );
            rawmesh.(fieldname)(:,actualNumber+1:expnumber) = ...
                zeros( size(rawmesh.(fieldname),1), expnumber-actualNumber );
            ok = false;
        end
    else
        fprintf( 1, 'Field %s should have any of', fieldname );
        fprintf( 1, ' %d', expnumber );
        fprintf( 1, ' parameters, %d parameters found.\n', actualNumber );
        ok = false;
        newexpnumber = min( expnumber(actualNumber < expnumber ) );
        if isempty(newexpnumber)
            newexpnumber = max( expnumber );
        end
        expnumber = newexpnumber;
        fprintf( 1, '    Amending to %d parameters.\n', newexpnumber );
    end
    rawmesh.(fieldname) = procrustesWidth( rawmesh.(fieldname), expnumber );
end


function mesh = meshFromRawMesh( rawmesh )
    if isempty( rawmesh )
        mesh = [];
        return;
    end
    
    % Validity checks.
    % 1. Each matrix should have the expected number of columns.
    [rawmesh,ok] = checkNumParams( rawmesh, 'v', 3 );
    [rawmesh,ok] = checkNumParams( rawmesh, 'f', [3,6] );
    [rawmesh,ok] = checkNumParams( rawmesh, 'x_growth', 4 );
    [rawmesh,ok] = checkNumParams( rawmesh, 'celllabel', 2 );

    numrawnodes = size(rawmesh.v,1);
    numtrivxs = size(rawmesh.f,1);
    
    % 2. Every node index must appear in rawmesh.f, and no other number may
    % appear there.
    usednodes = unique(rawmesh.f);
    nodesWithoutPosition = setdiff( usednodes, 1:numrawnodes );
    nodesWithoutCell = setdiff( 1:numrawnodes, usednodes );
    if length(nodesWithoutPosition) > 0
        numExtra = length(nodesWithoutPosition);
        fprintf( 1, 'The following %d nodes are used as cell vertexes but have no position data:\n  ', ...
            numExtra );
        fprintf( 1, '  %d', nodesWithoutPosition );
        fprintf( 1, '\n    Their coordinates will be set to zero.\n' );
        fprintf( 1, '    NB. This is not physically meaningful. The data should be corrected.\n' );
        rawmesh.v(numrawnodes+1,numrawnodes+numExtra,:) = zeros(numExtra,3);
    end
    if length(nodesWithoutCell) > 0
        fprintf( 1, 'The following nodes have position data but do not belong to any cell:\n  ' );
        fprintf( 1, '  %d', nodesWithoutCell );
        fprintf( 1, '\n    They will be ignored.\n' );
        % Need to delete these nodes and renumber.
        retainednodesmap = ones(numrawnodes,1);
        retainednodesmap(nodesWithoutCell) = 0;
        rawmesh.v = rawmesh.v(retainednodesmap==1,:);
        retainednodeindexes = (1:numrawnodes);
        retainednodeindexes = retainednodeindexes(retainednodesmap==1);
        renumbering = zeros(numrawnodes,1);
        renumbering(retainednodeindexes) = 1:(numrawnodes-size(nodesWithoutCell,2));
        rawmesh.f = renumbering(rawmesh.f);
    end
    
    % 3.  If there is growth data ('x_growth'), then it should be supplied
    % for every cell.
    if isfield(rawmesh,'x_growth')
        numgrowths = size(rawmesh.x_growth,1);
        if numgrowths < numtrivxs
            fprintf( 1, 'Morphogen values have only been provided for the first %d of %d cells.\n', ...
                numgrowths, numtrivxs );
            fprintf( 1, '    Morphogen values for the remaining cells are set to zero.\n' );
            rawmesh.x_growth(numgrowths+1:numtrivxs,size(rawmesh.x_growth,2)) = ...
                zeros( numtrivxs-numgrowths, size(rawmesh.x_growth,2) );
        elseif numgrowths > numtrivxs
            fprintf( 1, 'Morphogen values have been provided for %d cells, but the mesh only has %d cells.\n', ...
                numgrowths, numtrivxs );
            fprintf( 1, '    Extra morphogen values will be ignored.\n' );
            rawmesh.x_growth = rawmesh.x_growth( numtrivxs+1:numgrowths,:);
        end
    end
    
    % 4. Cell labels should only be provided for cells that exist.
    % Non-labelled cells are ok.
    if isfield( rawmesh, 'celllabel' )
        extraLabels = setdiff( rawmesh.celllabel(:,1), 1:numtrivxs );
        if length(extraLabels) > 0
            fprintf( 1, 'Labels were specified for the following nonexistent cells:\n  ' );
            fprintf( 1, '  %d', extraLabels );
            fprintf( 1, '\n    They will be ignored.\n' );
            rawmesh.celllabel = rawmesh.celllabel( ...
                (rawmesh.celllabel(:,1) > 0) && (rawmesh.celllabel(:,1) <= numtrivxs)...
                );
        end
    end
    
    % 5. If f is six wide, then the first three in each row must be odd and
    % one less than the second three.  When this is so we replace f by the
    % equivalent three-element version.
    if size(rawmesh.f,2)==6
        if ~all((rawmesh.f(:,1:3)+1)==rawmesh.f(:,4:6))
            fprintf( 1, 'Six-node cell descriptions fail to satisfy numbering rule [a b c a+1 b+1 c+1].\n' );
            ok = false;
        end
        numnodes = numrawnodes/2;
    else
        numnodes = numrawnodes;
    end
    
    %6. If growth information is specified, it must be specified for exactly
    %all the nodes.
    rawmesh = checkPerNode( rawmesh, 'g', numnodes );
    rawmesh = checkPerNode( rawmesh, 'gprod', numnodes );
    rawmesh = checkPerNode( rawmesh, 'gfix', numnodes );
    rawmesh = checkPerNode( rawmesh, 'gcl', numnodes );
    
    %7. Each of the global properties should have exactly the right width, and height 1.
%    [rawmesh,ok] = expectGlobSize( mesh.globalProps, rawmesh, 'K' );
%    for i=1:length(globFields)
%        [rawmesh,ok] = expectGlobSize( mesh.globalProps, rawmesh, globFields{i} );
%    end
    
    % Now build the mesh.
    
    if size(rawmesh.f,2)==6
        mesh.prismnodes = rawmesh.v;
        mesh.tricellvxs = int32(rawmesh.f(:,4:6)/2);
        mesh.globalProps.trinodesvalid = false;
        mesh.globalProps.prismnodesvalid = true;
    else
        mesh.nodes = rawmesh.v;
        mesh.tricellvxs = rawmesh.f;
      %  mesh.prismnodes = ...
      %      reshape( ...
      %          [ [mesh.nodes(:,1:2), mesh.nodes(:,3)-mesh.globalDynamicProps.thicknessAbsolute]'; mesh.nodes' ], ...
      %          size(mesh.nodes,1)*2, 3 );
        mesh.globalProps.trinodesvalid = true;
        mesh.globalProps.prismnodesvalid = false;
    end

    setGlobals();
    mesh = setmeshfromnodes( mesh );

    % The number of morphogens is given by rawmesh.g if it exists.
    if isfield( rawmesh, 'g' )
        numMorphogens = size( rawmesh.g, 2 );
        mesh = setNumMorphogens( mesh, numMorphogens );
    end
    globFields = fieldnames( mesh.globalProps );

    for i=1:length(globFields)
        [mesh,rawmesh] = getRawGlobalProp( mesh, rawmesh, globFields{i} );
    end

    if isfield( rawmesh, 'x_growth' )
        mesh = addAIHgrowthdata( mesh, rawmesh.x_growth(:,2:4) );
    end

    mesh = addrawdata( mesh, rawmesh, 'morphogens', 'g' );
    mesh = addrawdata( mesh, rawmesh, 'morphogenclamp', 'gcl' );

    if isfield( rawmesh, 'celllabel' )
        mesh.celllabel = zeros( numtrivxs, 1 );
        mesh.celllabel( rawmesh.celllabel(:,1) ) = rawmesh.celllabel(:,2);
    end
end

function [mesh,rawmesh] = getRawGlobalProp( mesh, rawmesh, field )
    [rawmesh,ok] = expectGlobSize( mesh.globalProps, rawmesh, field );
    if ok
        mesh.globalProps.(field) = ...
            reshape( rawmesh.(field), size(mesh.globalProps.(field)) );
    end
end

function [rawmesh,ok] = expectGlobSize( globs, rawmesh, field )
    ok = 1;
    if isfield(rawmesh,field) && isfield(globs,field)
        expected = numel(globs.(field));
        s = size(rawmesh.(field));
        height = s(1);
        actual = s(2);
        if height > 1
            fprintf( 1, ...
                'Multiple values (%d) provided for global property "%s". First value used.\n', ...
                height, field );
            rawmesh.(field) = rawmesh.(field)(1,:);
        end
        if actual ~= expected
            ok = 0;
            fprintf( 1, ...
                'Global property "%s" requires %d numbers, %d found.\n', ...
                field, expected, actual );
            if actual < expected
                fprintf( 1, '  Padding with zeros.\n' );
                rawmesh.(field)(1,actual+1:expected) = zeros(1,expected-actual);
            elseif actual > expected
                fprintf( 1, '  Ignoring extra values.\n' );
                rawmesh.(field) = rawmesh.(field)(1,1:expected);
            end
        end
    else
        ok = 0;
    end
end

function rawmesh = checkPerNode( rawmesh, field, numnodes )
    if isfield(rawmesh,field)
        num = size(rawmesh.(field),1);
        if num ~= numnodes
            fprintf( 1, ...
                '"%s" information supplied for %d nodes, but there are %d nodes in the surface mesh.\n', ...
                field, num, numnodes )
            if num < numnodes
                rawmesh.(field)(num+1:numnodes,:) = 0;
            else
                rawmesh.(field) = rawmesh.(field)(1:numnodes,:);
            end
        end
    end
end


function mesh = addrawdata( mesh, rawmesh, field, rawfield )
    if isfield( rawmesh, rawfield )
        mesh.(field) = rawmesh.(rawfield);
    end
end

