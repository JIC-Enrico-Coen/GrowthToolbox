function [s,errmsg] = xsprintf( varargin )
%s = xsprintf( ... )
%   An extensible replacement for sprintf.  This is called in exactly the
%   same way as sprintf.  Every format code %C for any character C is first
%   looked up in the global variable USER_FORMATS.  If defined, this should
%   be a containers.Map object whose keys are the format characters you
%   wish to define.  The value associated with each key should be a
%   handle to a function that will take a single argument of the expected
%   type and convert it to a string.
%
%   IN PROGRESS
%
%   See doc sprintf for complete syntax.
%   Unimplemented: #

%{
Ideas: want a format for printing arrays.  It would have to be able to
specify a format for each item, a separating string, multi-level
formatting, and terminators.

A format for strings to be printed at fixed width.

General syntax of format specifications.
Begins with '%'.
Digits, '.', '+', '-', and ',' never end a format.  Perhaps some other
characters as well, e.g. ';', ':'.
All types of bracket must match.
Escapes apply.
Array spec: a list of numbers, and a list of strings of the same length.
A number preceded by # means the corresponding dimension of the array.

Handlers must receive the arguments in some standard form.
%}

    global USER_FORMATS  % A containers.Map mapping characters to routines that convert to characters.
    
    errmsg = '';
    if isempty(USER_FORMATS)
        fprintf( varargin{:} );
        return;
    end
    
    if nargin==0
        return;
    end
    if ischar( varargin{1} )
        fmt = varargin{1};
        varargin = varargin(2:end);
    elseif nargin < 2
        return;
    end
    if isempty(varargin)
        return;
    end
    
    fmtpattern = '%(#?)([0-9]+\$)?((\.)?([-+0-9]*))*([a-zA-Z])';
    [strs,fmts] = splitString( fmtpattern, fmt );
    nstrs = length(strs);
    substrings = cell( 1, length(strs)+length(fmts) );
    si = 0;
    argcount = 0;
    for i=1:nstrs
        si = si+1;
        substrings{si} = strs{i};
        if i < nstrs
            fmt = fmts{i};
            [params,ishash,argnum,fmtchar] = parseFmt( fmt )
            fc = fmt(end);
            argcount = argcount+1;
            if argcount <= length(varargin)
                if isKey( USER_FORMATS, fc )
                    fmt = fmt(2:(end-1));
                    havehash = ~isempty(fmt) && (fmt(1)=='#');
                    if havehash
                        fmt = fmt(2:end);
                    end
                    paramstrs = splitString( '\.', fmt(2:(end-1)) );
                    params = zeros(1,length(paramstrs));
                    for j=1:length(paramstrs)
                        p = string2num(paramstrs);
                        if isempty(p)
                            params(j) = 0;
                        else
                            params(j) = p;
                        end
                    end
                    fn = USER_FORMATS(fc);
                    s = fn( varargin{argcount}, params );
                else
                    s = sprintf( fmt, varargin{argcount} );
                end
                si = si+1;
                substrings{si} = s;
            end
        end
    end


    % Walk through the string looking for % not followed by a code that
    % fprintf knows.
    
%     substrings = cell(1,0);
%     numstrings = 0;
%     argcount = 0;
%     cstart = 1;
%     i = 1;
%     while i <= length(fmt)
%         if fmt(i)=='%'
%             if i > cstart
%                 numstrings = numstrings+1;
%                 substrings{numstrings} = fmt(cstart:(i-1));
%             end
%             if i==length(fmt)
%                 % Ignore unterminated escape.
%                 i = i+1;
%             else
%                 fc = fmt(i+1);
%                 argcount = argcount+1;
%                 if argcount <= length(varargin)
%                     if isKey( USER_FORMATS, fc )
%                         % Invoke our own procedure
%                         callback = USER_FORMATS(fc);
%                         s = callback( varargin{argcount} );
%                     else
%                         % Use sprintf.
%                         s = sprintf( fmt(cstart:(i+1)), varargin{argcount} );
%                     end
%                     if ~isempty(s)
%                         numstrings = numstrings+1;
%                         substrings{numstrings} = s;
%                     end
%                 else
%                     % Ignore formats for missing arguments.
%                 end
%                 i = i+2;
%             end
%             cstart = i;
%         elseif fmt(i)=='\'
%             if i==length(fmt)
%                 % Ignore unterminated escape.
%                 i = i+1;
%             else
%                 numstrings = numstrings+1;
%                 substrings{numstrings} = [ fmt(cstart:(i-1)), unescape( fmt(i+1) ) ];
%                 i = i+2;
%                 cstart = i;
%             end
%         else
%             i = i+1;
%         end
%     end
%     if cstart <= length(fmt)
%         numstrings = numstrings+1;
%         substrings{numstrings} = fmt(cstart:length(fmt));
%     end
    s = cell2mat( substrings );
end

function [params,ishash,argnum,fmtchar] = parseFmt( fmt )
    fmtpattern = '%(#?)([0-9]+\$)?((\.)?([-+0-9]*))*([a-zA-Z])';
    toks = regexp( fmt, fmtpattern, 'tokens' );
    if isempty(toks)
        params = [];
        ishash = [];
        argnum = [];
        fmtchar = [];
    else
        if length(toks)==1
            toks = toks{1};
        end
        paramstr = toks{3};
        params = string2num( splitString( '\.', paramstr ) )';
        ishash = ~isempty(toks{1});
        argnum = string2num(toks{2});
        fmtchar = toks{4};
    end
    xxxx = 1;
end
