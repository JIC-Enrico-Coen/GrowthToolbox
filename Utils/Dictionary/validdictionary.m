function ok = validdictionary( d, complainer )
%ok = validdictionary( d, complainer )
%   Check the validity of a dictionary.
    
    if nargin < 2
        complainer = @warning;
    end
    [ok,missingfields,extrafields] = checkFields( d, { 'case', 'name2IndexMap', 'index2NameMap' }, {} );
    if ~ok
        complainer( 1, 'Invalid dictionary: ' );
        if ~isempty(missingfields)
            complainer( 1, ' missing fields {' );
            complainer( 1, ' %s', missingfields{:} );
            complainer( 1, ' }' );
        end
        if ~isempty(extrafields)
            complainer( 1, ' extra fields {' );
            complainer( 1, ' %s', extrafields{:} );
            complainer( 1, ' }' );
        end
        complainer( 1, '\n' );
        if ~isempty(missingfields)
            return;
        end
    end
    
    % index2NameMap must not include repetitions.
    if length(unique(d.index2NameMap)) < length(d.index2NameMap)
        ok = false;
        complainer( 1, 'Invalid dictionary: repeated names.  List of names is {' );
        complainer( 1, ' %s', extrafields{:} );
        complainer( 1, ' }\n' );
        return;
    end

    % name2IndexMap must have exactly the fields listed in index2NameMap.
    n2inames = fieldnames( d.name2IndexMap );
    [ok,missingfields,extrafields] = checkFields( d.name2IndexMap, d.index2NameMap, {} );
    if ~ok
        complainer( 1, 'Invalid dictionary: name2Index and index2Name are not consistent.\n' );
        if ~isempty(missingfields)
            complainer( 1, '    In name2Index but not index2Name {' );
            complainer( 1, ' %s', extrafields{:} );
            complainer( 1, ' }\n' );
        end
        if ~isempty(extrafields)
            complainer( 1, '    In index2Name but not name2Index {' );
            complainer( 1, ' %s', missingfields{:} );
            complainer( 1, ' }\n' );
        end
        complainer( 1, '\n' );
        return;
    end
    
    % The indexing must be consistent.
    numnames = length(d.index2NameMap);
    badrefs = true( 1, numnames );
    for i=1:numnames
        badrefs(i) = d.name2IndexMap.(d.index2NameMap{i}) ~= i;
    end
    if any(badrefs)
        complainer( 'Invalid dictionary: inconsistent indexing.\n' );
        for i=find(badrefs)
            complainer( '  i2n(%d) = %s,   n2i(%s) = %d\n', ...
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
            complainer( 1, 'Invalid dictionary: case field must be -1, 0 or 1, %g found.\n', d.case );
            ok = false;
            return;
    end
    badnames = true( 1, numnames );
    for i=1:numnames
        badnames = ~strcmp( forcedcase{i}, d.index2NameMap{i} );
    end
    if any(badnames)
        ok = false;
        complainer( 'Invalid dictionary: %s case found where %s expected.\n', wrongcase, rightcase );
        for i=find(badnames)
            complainer( 1, '    Found %s, should be %s.\n', d.index2NameMap{i}, forcedcase{i} );
        end
    end
end
