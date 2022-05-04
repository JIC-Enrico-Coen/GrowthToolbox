function ok = validdictionary( d, severity )
%ok = validdictionary( d, severity )
%   Check the validity of a dictionary.
    
    if nargin < 2
        severity = 0;
    end
    if severity==0
        fid = 1;
    else
        fid = 2;
    end
    
    [ok,missingfields,extrafields] = checkFields( d, { 'case', 'name2IndexMap', 'index2NameMap' }, {} );
    if ~ok
        complain2( severity, 'Invalid dictionary: ' );
        if ~isempty(missingfields)
            fprintf( fid, ' missing fields {' );
            fprintf( fid, ' %s', missingfields{:} );
            fprintf( fid, ' }' );
        end
        if ~isempty(extrafields)
            fprintf( fid, ' extra fields {' );
            fprintf( fid, ' %s', extrafields{:} );
            fprintf( fid, ' }' );
        end
        fprintf( fid, '\n' );
        if ~isempty(missingfields)
            return;
        end
    end
    
    % index2NameMap must not include repetitions.
    if length(unique(d.index2NameMap)) < length(d.index2NameMap)
        ok = false;
        complain2( severity, 'Invalid dictionary: repeated names.  List of names is {' );
        fprintf( fid, ' %s', extrafields{:} );
        fprintf( fid, ' }\n' );
        return;
    end

    % name2IndexMap must have exactly the fields listed in index2NameMap.
    n2inames = fieldnames( d.name2IndexMap );
    [ok,missingfields,extrafields] = checkFields( d.name2IndexMap, d.index2NameMap, {} );
    if ~ok
        complain2( severity, 'Invalid dictionary: name2Index and index2Name are not consistent.\n' );
        if ~isempty(missingfields)
            fprintf( fid, '    In name2Index but not index2Name {' );
            fprintf( fid, ' %s', extrafields{:} );
            fprintf( fid, ' }\n' );
        end
        if ~isempty(extrafields)
            fprintf( fid, '    In index2Name but not name2Index {' );
            fprintf( fid, ' %s', missingfields{:} );
            fprintf( fid, ' }\n' );
        end
        fprintf( fid, '\n' );
        return;
    end
    
    % The indexing must be consistent.
    numnames = length(d.index2NameMap);
    badrefs = true( 1, numnames );
    for i=1:numnames
        badrefs(i) = d.name2IndexMap.(d.index2NameMap{i}) ~= i;
    end
    if any(badrefs)
        complain2( severity, 'Invalid dictionary: inconsistent indexing.\n' );
        for i=find(badrefs)
            fprintf( fid, '  i2n(%d) = %s,   n2i(%s) = %d\n', ...
                i, d.index2NameMap{i}, d.index2NameMap{i}, d.name2IndexMap.(d.index2NameMap{i}) );
        end
    end
    
    
    % The case field must be -1, 0, or 1, and consistent with the case of
    % all the names.
    switch d.case
        case 0
            % No check.
            return;
        case -1
            forcedcase = lower( d.index2NameMap );
            rightcase = 'lower';
            wrongcase = 'upper';
            % Carry on.
        case 1
            forcedcase = upper( d.index2NameMap );
            rightcase = 'upper';
            wrongcase = 'lower';
            % Carry on.
        otherwise
            complain2( severity, 'Invalid dictionary: case field must be -1, 0 or 1, %g found.\n', d.case );
            ok = false;
            return;
    end
    badnames = true( 1, numnames );
    for i=1:numnames
        badnames = ~strcmp( forcedcase{i}, d.index2NameMap{i} );
    end
    if any(badnames)
        ok = false;
        complain2( severity, 'Invalid dictionary: %s case found where %s expected.\n', wrongcase, rightcase );
        for i=find(badnames)
            fprintf( fid, '    Found %s, should be %s.\n', d.index2NameMap{i}, forcedcase{i} );
        end
    end
end
