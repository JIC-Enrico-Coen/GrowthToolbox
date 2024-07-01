function [ts,s,err] = parseRSSS( ts, initvals )
%s = parseRSSS( ts )
%   Parse the token stream ts, returning a structure s.
%	The token stream is expected to be a description of the layout of a
%	figure or dialog, and s will be a data structure representing that
%	description.

    if nargin < 2
        initvals = [];
    end
    [ts,s,err] = parseRSSSvalue( ts, true, initvals );
    if ~isempty(s.children)
        s = s.children{1};
    end
end

function [ts,s,err] = parseRSSSvalue( ts, eos_ok, initvals )
% This is a recursive descent parser for the language I have defined for
% representing figure layouts. The language is not specific to that
% application and is a fairly general representation of hierarchical data
% structures.

%   node  ::=  NAME '{' ( attribute | node )* '}'
%   attribute  ::=  NAME value
%   value  ::=  STRING | NUMBER+
%
%   NAME is the lexical class [A-Za-z0-9_]+ beginning with a letter.
%
%   NUMBER is anything that looks like a number.
%
%   STRING is any sequence of characters, provided that if it contains
%   special characters it must be quoted, otherwise it may but need not be
%   quoted. The usual character escapes apply within quoted strings.
%
%   The value actually returned when a value is parsed depends on the
%   preceding attribute name.  For each attribute name, only certain types
%   and numbers of arguments are valid.  That is all checked by hard-coding
%   rather than lookup tables (which would be a cleaner way of doing it).

    err = false;
    s.attribs = struct();
    s.children = {};
    while true
        [ts,t,eos] = readtoken( ts );
        if eos
            err = ~eos_ok;
            if err
                unexpected( ts, 'End of stream' );
            end
            return;
        end
        if strcmp(t,'{')
            unexpected( ts, 'token ''{''' );
            err = true;
            return;
        end
        if strcmp(t,'}')
            return;
        end
        if ~isfieldname(t)
            unexpected( ts, 'parseRSSS: bad field name "%s"', t );
            err = true;
            return;
        end
        if strcmp( t, 'include' )
            [ts,includefile] = readtoken( ts );
            if isempty(includefile)
                reportParseError( ts, '"include" must be followed by a file name.\n' );
                err = true;
                return;
            end
            ts1 = opentokenstream( includefile );
            if isempty( ts1 )
                fprintf( 1, 'Could not open file "%s".\n', includefile );
                err = true;
                return;
            else
                ts = concattokenstreams( ts1, ts );
            end
        else
            % We have read a node type or attribute name.  A node type must
            % be followed by a list of its children enclosed in braces
            % (even if this is the empty list), and an attribute must be
            % followed by its value.
            [ts,t1,eos] = readtoken( ts );
            if eos
                err = true;
                unexpected( ts, 'End of stream' );
                return;
            end
            if strcmp(t1,'}')
                unexpected( ts, 'Token ''}''' );
                err = true;
                return;
            end
            if strcmp(t1,'{')
                % This is a child node.  Parse all of its attribute and
                % children, and swallow up the closing '}' that matches the
                % '{' that we just read.
                [ts,s1,err] = parseRSSSvalue( ts, false, initvals );
                s1.type = t;
                s.children{end+1} = s1;
                if err, return; end
            else
                % This is an attribute.  Parse its value.  Consecutive
                % numeric arguments are amalgamated into a single string of
                % space-separated numbers.  The test for numericity is
                % merely that the first character is a digit, a sign, or a
                % decimal point.
                if seemsNumeric( t1 )
                    t2 = t1;
                    while true
                        [ts,t1,eos] = readtoken( ts );
                        if eos
                            break;
                        elseif seemsNumeric( t1 )
                            t2 = [ t2, ' ', t1 ];
                        else
                            ts = putback( ts, t1 );
                            break;
                        end
                    end
                    t1 = t2;
                end
                [s.attribs.(t), initvals] = convertAttribType( ts, t, t1, initvals );
            end
        end
    end
end

function sn = seemsNumeric( t )
    sn =  ~isempty( regexp( t, '^[0-9-+.]', 'once' ) );
end

function [n,errmsg] = parseNumbers( token, fmt, minnums, maxnums )
    errmsg = '';
    if isnumeric( token )
        n = length(token);
    else
        [n,count,msg,index] = sscanf( token, fmt );
        if index <= length(token)
            errmsg = sprintf( 'Extra found after reading %d numbers: ''%s''.\n', ...
                count, token(index:end) );
        end
    end
    n = n(:)';
    if (nargin >= 3) && (count < minnums)
        errmsg = sprintf( '%d numbers expected but %d found.\n', minnums, count );
    end
    if nargin < 4
        maxnums = minnums;
    end
    if count > maxnums
        errmsg = sprintf( '%d numbers expected but %d found.\n', maxnums, count );
    end
end

function [t2,initvals] = convertAttribType( ts, t, t1, initvals )
    i = regexp( t1, '\^', 'once' );
    if ~isempty(i)
        tag = t1((i+1):end);
        if isfield( initvals, tag )
            t2 = initvals.(tag);
            return;
        else
            t1 = t1(1:(i-1));
        end
    end
    errmsg = '';
    switch t
        case { 'value', 'fontsize', ...
               'lines', 'rows', 'columns', 'min', 'max', ...
               'minorstep', 'majorstep', ...
               'LineWidth' }
            [t2,errmsg] = parseNumbers( t1, '%f', 1 );
        case { 'margin', 'outermargin' }
            [t2,errmsg] = parseNumbers( t1, '%f', 1, 4 );
            switch length(t2)
                case 1
                    t2 = [t2 t2 t2 t2];
                case 2
                    t2 = t2([1 1 2 2]);
                case 3
                    t2(4) = t2(3);
                otherwise
            end
        case { 'innermargin' }
            [t2,errmsg] = parseNumbers( t1, '%f', 1, 2 );
            if length(t2)==1
                t2 = [t2 t2];
            end
        case { 'selectedchild' }
            [t2,errmsg] = parseNumbers( t1, '%d', 1 );
        case { 'minsize' }
            [t2,errmsg] = parseNumbers( t1, '%f', 1, 2 );
        case { 'color', 'backgroundcolor', 'foregroundcolor', 'shadowcolor', 'highlightcolor', 'textcolor' }
            [t2,errmsg] = parseNumbers( t1, '%f', 3 );
        case { 'multiline', 'equalwidths', 'equalheights', 'square', 'singlechild' }
            t1 = lower(t1);
            t2 = strcmp( t1, 'yes' ) || strcmp( t1, 'true' );
        otherwise
            t2 = t1;
    end
    if ~isempty(errmsg)
        reportParseError( ts, '%s', errmsg );
    end
end

function reportParseError( ts, varargin )
    if isempty( ts.name )
        fprintf( 1, 'Error on line %d: ', ts.curline );
    else
        fprintf( 1, 'Error on line %d of file "%s": ', ts.curline, ts.name );
    end
    fprintf( 1, varargin{:} );
end

            

function unexpected( ts, varargin )
    fprintf( 1, varargin{:} );
    fprintf( 1, ' at token %d of line %d of %s.\n', ts.curtok, ts.curline, ts.name );
end

function ok = isfieldname(t)
    ok = ~isempty( regexp( t, '^[A-Za-z][A-Za-z_0-9]*$', 'once' ) );
end
