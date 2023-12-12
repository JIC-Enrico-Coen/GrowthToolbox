function result = compareStructs( s1, s2, varargin )
%compareStructs( s1, s2, ... )
%   Compare two structs, reporting which fields in either are not in the
%   other, and for common fields, whether their contents differ.
%
%   s1 and s2 are the two structs.
%
%   The remaining arguments are option names and option values.  Possible
%   options are:
%
%   outputfile: The name of the file to report results to.  If empty or
%       omitted, output is sent to the console.
%
%   reportok: If true, fields which match will be reported as well as
%       fields which do not match.  If false (the default) only non-matches
%       are reported.
%
%   tolerance: The maximum allowed absolute difference between floating
%       point values for them to be regarded as "the same".  The default is
%       zero: every difference is considered a difference.
%
%   maxnum: For struct arrays, the maximum number of elements that will be
%       reported on individually. By default, 20.
%
%   silent: If true, no report will be made (and no output file opened, if
%       specified), and the procedure will return as soon as any difference
%       is found.  The default is false.
%
%   NOT IMPLEMENTED: path specifies a part of the struct to limit the
%   comparison to.  This is a single field name or a sequence of them
%   joined by a dot.
%
%   The result is true if the structs are compatible, false otherwise.  The
%   result will also be false if there are other errors, e.g. the output
%   file cannot be created, or misspelled options.
%
%   Compatibility is not identity.  Two sorts of difference are allowed.
%   One is numerical differences no larger than the tolerance. The other is
%   type differences.  An integer field in one corresponding to a double
%   field in the other will be reported, but (if the values are otherwise
%   equal) will not cause a false result to be returned.

    result = false;
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'outputfile', '', 'reportok', false, 'tolerance', 0, 'maxnum', 20, 'silent', false );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'outputfile', 'reportok', 'tolerance', 'maxnum', 'silent' );
    if ~ok, return; end

    result = true;
    fid = -1;
    if isempty(s.outputfile)
        fid = 1;
    elseif ~s.silent
        fid = fopen( s.outputfile, 'w' );
        if fid == -1
            fprintf( 1, '%s: Cannot open output file %s.\n', mfilename(), s.outputfile );
            return;
        end
    end
    
    result = compareStructs1( fid, s1, s2, s.reportok, s.tolerance, 'ROOT', s.maxnum, s.silent, {} );
end

function compatible = compareStructs1( fid, s1, s2, reportCompatible, tolerance, path, maxnum, silent, nofollow )
%ok = compareStructs1( fid, s1, s2, reportCompatible )
%   Report on any differences of structure between s1 and s2.
%   A difference of structure is:
%       s1 and s2 are of different classes.
%       s1 and s2 are both arrays, struct arrays, or cell arrays, but have
%           different shapes. 
%       s1 and s2 are both structs, but have different sets of fields.
%       s1 and s2 are both structs, but for some field f belonging to both,
%           s1.f and s2.f have an incompatibility.
%   The result is true iff there are no incompatibilities.
%
%   If reportCompatible is true, compatible components of s1 and s2 will be
%   reported, otherwise only incompatibilities will be reported.
%
%   tolerance defaults to 0, and is the largest difference allowed between
%   numeric values deemed to be the same.

%   The PATH argument is for internal use.  It records where we are in the
%   data structure for the purpose of generating output during recursive calls.
%
%   If SILENT is true then no report will be made, and the procedure will
%   return as soon as an incompatibility is found.

    compatible = true;
    reportCompatible = reportCompatible && ~silent;
    
    % Check they are the same class.
    c1 = class(s1);
    c2 = class(s2);
    if ~strcmp(c1,c2)
        compatible = false;
        if ~silent
            fprintf( fid, 'At %s, classes are %s and %s.\n', ...
                path, c1, c2 );
        end
        return;
    end
    
    % Check they are the same size.
    sz1 = size(s1);
    sz2 = size(s2);
    if (length(sz1) ~= length(sz2)) || any(sz1 ~= sz2)
        compatible = false;
        if ~silent
            fprintf( fid, 'At %s, class %s, sizes are [', path, c1 );
            fprintf( fid, ' %d', sz1 );
            fprintf( fid, ' ] and [' );
            fprintf( fid, ' %d', sz2 );
            fprintf( fid, ' ].\n' );
        end
        return;
    end
    
    % Check integers, logicals, and chars for identity.
    if (islogical(s1) || isinteger(s1) || ischar(s1)) && (islogical(s2) || isinteger(s2) || ischar(s2))
        numdiffs = sum( s1(:) ~= s2(:) );
        if numdiffs > 0
            compatible = false;
            if ~silent
                fprintf( fid, 'At %s, class %s, elements differ in %d of %d places.\n', path, c1, numdiffs, numel(s1) );
            end
            return;
        end
        if reportCompatible && compatible
            fprintf( fid, 'Compatible at %s\n', path );
        end
        return;
    end
    
    % Check reals for identity to within tolerance.
    if isnumeric(s1) && isnumeric(s2)
        numdiffs = sum( abs(double(s1(:)) - double(s2(:))) > tolerance );
        if numdiffs > 0
            compatible = false;
            if ~silent
                if tolerance==0
                    fprintf( fid, 'At %s, class %s, elements differ in %d of %d places.\n', path, c1, numdiffs, numel(s1) );
                else
                    fprintf( fid, 'At %s, class %s, elements differ in %d of %d places by more than %g.\n', path, c1, numdiffs, numel(s1), tolerance );
                end
            end
        end
        if reportCompatible && compatible
            fprintf( fid, 'Compatible at %s\n', path );
        end
        return;
    end
    
    % Compare cell arrays element by element.
    if iscell(s1) && iscell(s2)
        for i=1:min(numel(s1),numel(s2))
            ok = compareStructs1( fid, s1{i}, s2{i}, ...
                reportCompatible, tolerance, sprintf( '%s.{%d}', path, i ), maxnum, true, nofollow );
            compatible = compatible && ok;
            if ~compatible
                if ~silent
                    fprintf( fid, 'At %s, cell arrays differ at item %d (and possibly others) of %d.\n', path, i, numel(s1) );
                end
                return;
            end
        end
        if reportCompatible && compatible
            fprintf( fid, 'Compatible at %s\n', path );
        end
        return;
    end
    
    % Compare structs.
    if isstruct(s1)
        % Check they have the same field names.
        f1 = fieldnames(s1);
        f2 = fieldnames(s2);
        f1minus2 = setdiff(f1,f2);
        f2minus1 = setdiff(f2,f1);
        f12 = intersect(f1,f2);
        f12 = setdiff( f12, nofollow );
        if ~isempty(f1minus2)
            compatible = false;
            if silent
                return;
            else
                fprintf( fid, 'At %s, these fields occur only in the first struct:\n   ', path );
                fprintf( fid, ' %s', f1minus2{:} );
                fprintf( fid, '\n' );
            end
        end
        if ~isempty(f2minus1)
            compatible = false;
            if silent
                return;
            else
                fprintf( fid, 'At %s, these fields occur only in the second struct:\n   ', path );
                fprintf( fid, ' %s', f2minus1{:} );
                fprintf( fid, '\n' );
            end
        end
        
        % Compare corresponding field values.
        n = min(numel(s1),numel(s2));
        if n==1
            for i=1:length(f12)
                fn = f12{i};
                ok = compareStructs1( fid, s1.(fn), s2.(fn), ...
                    reportCompatible, tolerance, [ path, '.', fn ], maxnum, silent, nofollow );
                compatible = compatible && ok;
                if silent && ~compatible
                    return;
                end
            end
        elseif n > 1
            compat1 = true;
            reported = false;
            for si=1:n
                if si > maxnum
                    xxxx = 1;
                end
                oks = false(1,length(f12));
                for i=1:length(f12)
                    oks(i) = compareStructs1( fid, s1(si).(f12{i}), s2(si).(f12{i}), ...
                        reportCompatible, tolerance, [ path, sprintf( '(%d).', si ), f12{i} ], maxnum, si > maxnum, nofollow );
                    compat1 = compat1 && oks(i);
                    if silent && ~compat1
                        return;
                    end
                end
                reported = reported || ((~silent) && any(oks) && (si <= maxnum));
                if (si >= maxnum)
                    if ~compat1
                        break;
                    end
                end
            end
            if ~silent && ~compat1 && ~reported
                fprintf( fid, 'At %s, struct arrays have different values in at least one field.\n', ...
                    path );
            end
            compatible = compatible && compat1;
        end
        if reportCompatible && compatible
            fprintf( fid, 'Compatible at %s\n', path );
        end
        return;
    end
    
    % Try simple equality.
    try
        if all( s1(:)==s2(:) )
            if reportCompatible
                fprintf( fid, 'Compatible at %s\n', path );
            end
            return;
        end
    catch
        % Equality didn't work. Try something else.
    end
    
    % Deleted handles are deemed to all be the same, but different from
    % extant handles.
    isdh1 = isDeletedHandle( s1 );
    isdh2 = isDeletedHandle( s2 );
    if any( isdh1(:) ~= isdh2(:) )
        compatible = false;
        if ~silent
            fprintf( fid, 'At %s, some handles are deleted and some not.\n', path );
        end
        return;
    end
    if all( isdh1(:) )
        % They consist entirely of deleted handles.
        if reportCompatible
            fprintf( fid, 'Compatible at %s (deleted handles of class %s)\n', path, c1 );
        end
        return;
    end
    
    % Try converting the objects to structures.
    try
        ss1 = get( s1 );
        ss2 = get( s2 );
        compatible = compareStructs1( fid, ss1, ss2, reportCompatible, tolerance, path, maxnum, silent, [ nofollow, 'Parent' ] );
        if reportCompatible
            fprintf( fid, 'Compatible at %s\n', path );
        end
        return;
    catch
        % The objects do not support the get() function.
    end
    
    % Try direct equality.
    try
        equal = s1==s2;
        compatible = equal;
        if compatible
            if reportCompatible
                fprintf( fid, 'Compatible at %s, class %s.\n', path, c1 );
            end
        else
            fprintf( fid, 'At %s, class %s, elements differ.\n', path, c1 );
        end
        return;
    catch
        % They do not support equality.
    end
    
    % As a last resort, try converting them to text.
    try
        st1 = formattedDisplayText(s1);
        st2 = formattedDisplayText(s2);
        compatible = strcmp( st1, st2 );
        if compatible
            if reportCompatible
                fprintf( fid, 'Compatible at %s, class %s.\n', path, c1 );
            end
        else
            if ~silent
                fprintf( fid, 'At %s, objects of class %s differ.\n%s%s', ...
                    path, c1, st1, st2 );
            end
        end
        return;
    catch
        % The objects do not support conversion to text.
    end

    % We can find no way of comparing these. We do not count this as an
    % incompatibility, but we do print a message if we are printing any
    % messages.
    if ~silent
        fprintf( fid, 'At %s, Matlab classes of type %s cannot be compared. Treated as equal.\n', ...
            path, c1 );
    end
end
