function [fixdfs,freedfs] = convertXYZtoDFs( dfs )
%dfbits = convertXYZtoDFs( dfs )
%   This is used by leaf_fix_vertex and leaf_locate_vertex to parse a
%   string DFS specifying sets of degrees of freedom along which a vertex
%   is to be fixed or free to move.  FIXDFS and FREEDFS are boolean vectors
%   of length 3 which are never both true.
%
%   DFS has one of the following forms:
%   1.  A subset of the characters 'xyz'. Upper and lower case are not
%       distinguished. FIXDFS is true for each character present, and
%       FREEDFS is true for the others.
%   2.  A series of substrings, each being a '+' or '-' followed by a
%       subset of 'xyz'.  '+' means that the following degrees of freedom
%       are to be fixed, '-' means they are to be free.  If a letter
%       appears in more than one such substring, the last occurrence is the
%       one that will be used.  Thus '+xy-x' is equivalent to '+y-x'.
%       For letters not appearing anywhere in the string, constraints on
%       the corresponding degrees of freedom are left unchanged.
%
%   Unknown characters in DFS are ignored.

    dfs = lower(dfs);
    dfstatus = zeros(1,3);
    s = 2;
    for i=1:length(dfs)
        switch dfs(i)
            case '+'
                s = 1;
            case '-'
                s = -1;
            case 'x'
                dfstatus(1) = s;
            case 'y'
                dfstatus(2) = s;
            case 'z'
                dfstatus(3) = s;
        end
    end
    if s==2
        % DFS does not contain any '+' or '-'.  Unspecified degrees of
        % freedom are to be free.
        fixdfs = dfstatus > 0;
        freedfs = ~fixdfs;
    else
        % DFS does contain at least one '+' or '-'.  Unspecified degrees of
        % freedom are to be left unchanged.
        fixdfs = dfstatus > 0;
        freedfs = dfstatus < 0;
    end
end
